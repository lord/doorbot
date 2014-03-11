require './app'

client = Twilio::REST::Client.new ENV['TWILIO_SID'], ENV['TWILIO_TOKEN']
last_message = client.account.sms.messages.list.first.sid

while true
  messages = client.account.sms.messages.list
  messages.each do |sms|
    break if sms.sid == last_message
    if sms.from != '+17864225374' # ignore outgoing texts
      if User.where(phone: sms.from).exists? and sms.body.downcase.strip =~ Regexp.new(ENV['PASSWORD_REGEX'])
        puts "Unlock!"
        unlock
      else
        puts "Fail"
      end
    end
  end
  last_message = messages.first.sid
  sleep 1
end
