puts "Doorbot booting..."

require 'active_record'
require 'json'
require 'twilio-ruby'
require 'phone'
require './lib/models'
require './lib/greeter'
require './lib/unlocker'
require './lib/twilio_watcher'
require './lib/zulip_watcher'

unlocker = Unlocker.new
threads = []
threads << TwilioWatcher.new(unlocker).thread
threads << ZulipWatcher.new(unlocker).thread

puts "Doorbot finished booting"

threads.each do |thread|
  thread.join
end
