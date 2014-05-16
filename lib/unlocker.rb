require 'pi_piper'
require 'thread'

class Unlocker
  def initialize
    @timer = 0
    @unlocked = false
    @relay = PiPiper::Pin.new(:pin => 4, :direction => :out)
    set_lock
    @thread = Thread.new { start }
    @mutex = Mutex.new
  end

  def unlock(time=8000)
    @mutex.synchronize {
    if @unlocked == false
      @unlocked = true
      @timer = time
      set_unlock
      true
    else
      false
    end
    }
  end

  private

  def lock
    set_lock if @unlocked == true
    @unlocked = false
    @timer = 0
  end

  def set_unlock
    @relay.on
  end

  def set_lock
    @relay.off
  end

  def start
    loop do
      @mutex.synchronize {
      @timer -= 100 if @timer > 0
      lock if @timer <= 0 && @unlocked == true
      }
      sleep 0.1
    end
  end
end
