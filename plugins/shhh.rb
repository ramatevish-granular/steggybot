require 'cinch'

class Shhh
  include Cinch::Plugin

  $authorized_users = ["czhangolin", "steggy", "wsong"]

  match /quiet/, method: :be_quiet

  match /quiet --f (.+)/, method: :force_quit
  @help_hash = {
    :mute => "Usage: !quiet
Example: !quiet
Leaves if there's a name conflict or certain people ask"
  }

  def be_quiet(m)
    username_to_check = bot.nick.gsub("_", "")

    while username_to_check.length < bot.nick.length
      if m.channel.has_user?(username_to_check)
        m.reply("FINE, BE THAT WAY")
        bot.quit("its meeeeee, im the copy, nooooooo")
      end
      username_to_check += "_"
    end
  end

  def force_quit(m, username)
    return unless username == bot.nick.downcase

    if m.channel.opped?(m.user) || $authorized_users.include?(m.user.nick.downcase)
      bot.quit("bye")
    else
      m.reply("you are not on the sudoers list. this attempt has been reported.")
    end
  end
end
