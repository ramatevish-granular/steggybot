require 'cinch'
Dir.glob("plugins/*.rb").each {|x| require_relative x}

bot = Cinch::Bot.new do
  configure do |c|
    c.server = "irc.freenode.net"
    c.nick = "steggybot"
    c.channels = ["#csua", "#csuatest", "##csua"]
    c.plugins.plugins = [Google, UrbanDictionary, TitleGrabber, Quotes, Pokedex, Youtube, YaBish, Roll, WhoAreThesePeople, PlusPlus, Pazudora]
    c.plugins.plugins << Help
    c.plugins.options[Quotes] = {
      :quotes_file => "quotes.yml"
    }
    c.plugins.options[Pokedex] = {
      :pokedex => "pokedex.json"
    }
    c.plugins.options[WhoAreThesePeople] = {
      :identities => "identities.yml"
    }
    c.plugins.options[PlusPlus] = {
      :plusplus => "plusplus.yml"
    }
    c.plugins.options[Pazudora] = {
      :pddata => "pddata.yml"
    }
  end
end

bot.start
