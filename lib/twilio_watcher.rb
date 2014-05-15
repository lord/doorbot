class TwilioWatcher
  def initialize(unlocker)
    @unlocker = unlocker
    @client = Twilio::REST::Client.new ENV['TWILIO_SID'], ENV['TWILIO_TOKEN']
    @last_message = @client.account.sms.messages.list.first.sid
    @thread = Thread.new { start }
  end

  def start
    while true
      messages = @client.account.sms.messages.list
      messages.each do |sms|
        break if sms.sid == @last_message
        if sms.from != ENV['TWILIO_PHONE_NUMBER'] # ignore outgoing texts
          user_exists = User.where(phone: sms.from).exists?
          if user_exists and sms.body.downcase.strip =~ Regexp.new(ENV['PASSWORD_REGEX'])
            if @unlocker.unlock
              msg sms.from, "Door unlocked! #{greeting}"
            else
              msg sms.from, "Door was already unlocked."
            end
          elsif user_exists
            msg sms.from, "Sorry, incorrect password."
          else
            msg sms.from, "Sorry, I didn't recognize your phone number."
          end
        end
      end
      @last_message = messages.first.sid
      sleep 1
    end
  end

  private
  def msg(phone, msg)
    @client.account.messages.create(
      :from => ENV['TWILIO_PHONE_NUMBER'],
      :to => phone,
      :body => msg
    )
  end
end