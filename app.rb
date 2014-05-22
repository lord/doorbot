require 'active_record'
require 'json'
require 'twilio-ruby'
require 'phone'
require './lib/models'
require './lib/greeter'
require './lib/unlocker'
require './lib/twilio_watcher'
require './lib/zulip_watcher'

def new_twilio_client
  return Twilio::REST::Client.new ENV['TWILIO_SID'], ENV['TWILIO_TOKEN']
end

$unlocker = Unlocker.new
threads = []
threads << TwilioWatcher.new($unlocker).thread
threads << ZulipWatcher.new($unlocker).thread

threads.each do |thread|
  thread.join
end
