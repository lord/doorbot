require 'zulip'

class ZulipWatcher
  def initialize(unlocker)
    @unlocker = unlocker
    @client = ::Zulip::Client.new do |config|
      config.email_address = ENV['ZULIP_USERNAME']
      config.api_key = ENV['ZULIP_PASSWORD']
    end
    @thread = Thread.new { start }
  end

  def start
    @client.subscribe 'test-bot'
    @client.subscribe '455 Broadway'
    @client.stream_messages do |message|
      next if message.sender_email == ENV['ZULIP_USERNAME'] # Skip our own messages

      if message.type == 'private'
        content = message.content.downcase
        if content =~ /unlock/
          @unlocker.unlock
          send_msg "Door unlocked!", message.sender_email
        elsif content =~ /help/
          send_msg "I have a couple of commands! Say `unlock` to unlock, `phone <phone number>` to set your phone number, and `help` to show this help message.", message.sender_email
        elsif content =~ /phone/
          num = content.match(/phone +([\+\d\- \(\)]*)/)

          if num
            parsed_num = parse_phone_number num[1]
            if parsed_num == false
              send_msg "Sorry, I didn't recognize that phone number as a valid. Did you perhaps mistype something?", message.sender_email
            else
              user = User.find_or_create_by(zulip_email: message.sender_email)
              user.phone = parsed_num
              user.save
              send_msg "Got it! Your phone number is set to #{parsed_num}, which can now text '#{ENV['PASSWORD_HUMAN']}' to #{ENV['TWILIO_PHONE_NUMBER_HUMAN']} to unlock the downstairs door. (Note: if you previously set a phone number, it has been overwritten.) Have a wonderful day!", message.sender_email
            end
          else
            user = User.where(zulip_email: message.sender_email)
            if user.exists?
              send_msg "Your phone number is #{user.first.phone}. Text '#{ENV['PASSWORD_HUMAN']}' to #{ENV['TWILIO_PHONE_NUMBER_HUMAN']} to unlock the downstairs door.", message.sender_email
            else
              send_msg "Sorry, it doesn't look like you've set your phone number. Say `phone <phone_number>` to set one.", message.sender_email
            end
          end
        end
      elsif ['test-bot', '455 Broadway'].include?(message.stream) && message.content.downcase =~ /doorbot[,. ]+unlock/
        @unlocker.unlock
        @client.send_message(message.subject, "Door unlocked!", message.stream)
      end
    end
  end

  private
  def send_msg(msg, email)
    @client.send_private_message(msg, email)
  end
end