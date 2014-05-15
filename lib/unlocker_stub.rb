class Unlocker
  def initialize
    @timer = 0
    @unlocked = false
    set_lock
    @thread = Thread.new { start }
  end

  def unlock(time=8000)
    if @unlocked == false
      @unlocked = true
      @timer = time
      set_unlock
      true
    else
      false
    end
  end

  def lock
    set_lock if @unlocked == true
    @unlocked = false
    @timer = 0
  end

  private
  def set_unlock
    puts "Unlocked!"
  end

  def set_lock
    puts "Locked!"
  end

  def start
    loop do
      @timer -= 100 if @timer > 0
      lock if @timer <= 0 && @unlocked == true
      sleep 0.1
    end
  end
end
