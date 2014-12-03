require 'cinch'

class Countdown
  include Cinch::Plugin
  match /countdown/

  def execute(m)
    m.reply "There are no countdowns active."
  end
end
