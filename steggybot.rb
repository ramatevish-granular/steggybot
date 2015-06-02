require 'cinch'
Dir.glob("plugins/*.rb").each {|x| require_relative x}
Dir.glob("plugins/*/*.rb").each {|x| require_relative x}

bot = Cinch::Bot.new do
  configure do |c|
    c.server = "irc.freenode.net"
    c.nick = "steggybot"
    c.channels = ["#csua", "#csuatest"]
    c.plugins.plugins = [Google, UrbanDictionary, TitleGrabber, Quotes, Pokedex, Youtube, Ping,
                         Roll, WhoAreThesePeople, PlusPlus, Pazudora, Contributors, Countdown, FrenchRevCal, FeatureRequest]
    c.plugins.plugins << Help
    c.plugins.options[YaBish] = {
      :db => 'db/ya_bish',
      :rate_limit => [10, 600], # 10 replies every 600 seconds (10 min.)
      :random_ratio => (1.0/80), # reply randomly with a 1/80 probability
    }
    c.plugins.options[Quotes] = {
      :quotes_file => "db/quotes.yml"
    }
    c.plugins.options[Pokedex] = {
      :pokedex => "db/pokedex.json"
    }
    c.plugins.options[WhoAreThesePeople] = {
      :identities => "db/identities.yml"
    }
    c.plugins.options[PlusPlus] = {
      :plusplus => "db/plusplus.yml"
    }
    c.plugins.options[Pazudora] = {
      :pddata => "db/pddata.yml"
    }
    c.plugins.options[FeatureRequest] = {
      :requests => "db/requests.yml"
    }
    c.plugins.options[Ping] = {
      :ping => "db/ping.yml"
    }
  end
end

bot.start
