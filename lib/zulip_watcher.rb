require 'zulip'

class ZulipWatcher
  attr_reader :thread

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
          if @unlocker.unlock
            send_msg "Door unlocked! #{Greeter.greet}", message.sender_email
          else
            send_msg "Whoops, look like somebody just unlocked the door. Please wait a couple seconds before unlocking it again.", message.sender_email
          end
        elsif content =~ /help/
          send_msg "I have a couple of commands! Say `unlock` to unlock, `phone <phone number>` to set your phone number, and `help` to show this help message.", message.sender_email
          send_status_msg message.sender_email
        elsif content =~ /phone/
          num = content.match(/[\+\d\- \(\)]*\d+[\+\d\- \(\)]*/)

          if num
            parsed_num = parse_phone_number num[0]
            if parsed_num
              user = User.find_or_create_by(zulip_email: message.sender_email)
              user.phone = parsed_num
              user.save
              send_msg "Got it! Your phone number has been set to #{parsed_num}, which can now text '#{ENV['PASSWORD_HUMAN']}' to #{ENV['TWILIO_PHONE_NUMBER_HUMAN']} to unlock the downstairs door. (Note: if you previously set a phone number, it has been overwritten.)", message.sender_email
            else
              send_msg "Sorry, I didn't recognize that phone number as a valid. Did you perhaps mistype something?", message.sender_email
            end
          else
            send_status_msg message.sender_email
          end
        elsif content =~ /love/
          send_msg "I'm sorry, #{message.sender_short_name}, but as an automated bot, I am incapable of understanding love.", message.sender_email
        else
          send_msg "Sorry, I don't understand. Ask me for `help` if you need a list of commands.", message.sender_email
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

  def send_status_msg(email)
    user = User.where(zulip_email: email)
    if user.exists?
      send_msg "Your phone number is set as #{user.first.phone}. Text '#{ENV['PASSWORD_HUMAN']}' to #{ENV['TWILIO_PHONE_NUMBER_HUMAN']} to unlock the downstairs door.", email
    else
      send_msg "It doesn't look like you've set your phone. To unlock via text, you'll need to tell me your mobile number.", email
    end
  end

  def parse_phone_number(num)
    begin
      Phoner::Phone.default_country_code = '1'
      Phoner::Phone.parse(num).to_s
    rescue Phoner::PhoneError
      false
    end
  end
end