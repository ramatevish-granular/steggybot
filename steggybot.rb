require 'cinch'
Dir.glob("plugins/*").each {|x| require_relative x}

bot = Cinch::Bot.new do
  configure do |c|
    c.server = "irc.freenode.net"
    c.nick = "steggybot"
    c.channels = ["#csua", "#csuatest"]
    c.plugins.plugins = [Google, UrbanDictionary, TitleGrabber, Cinch::Plugins::Quotes, Pokedex, Youtube]
    c.plugins.options[Cinch::Plugins::Quotes] = {
      :quotes_file => "quotes.yml"
    }
  end
end

bot.start
