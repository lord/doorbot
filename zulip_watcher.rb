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
        msg = message.content.downcase
        if msg =~ /unlock/
          @unlocker.unlock
          @client.send_private_message("Door unlocked!", message.sender_email)
        elsif msg =~ /help/
          @client.send_private_message("I have a couple of commands! Say `unlock` to unlock, and `help` to show this help message", message.sender_email)
        end
      elsif ['test-bot', '455 Broadway'].include?(message.stream) && message.content.downcase =~ /doorbot[,. ]+unlock/
        @unlocker.unlock
        @client.send_message(message.subject, "Door unlocked!", message.stream)
      end
    end
  end
end