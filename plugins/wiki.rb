require 'cinch'
require 'open-uri'
require 'nokogiri'
require 'cgi'
require 'json'

class Wiki
  include Cinch::Plugin
  match /wiki (.+)/, method: :execute

  @help_hash = {
    :google => "Usage: !wiki THING
Example !wiki Syria
Returns the first wiki page for THING"
  }
  

  def wiki(query)
    url = "https://en.wikipedia.org/w/index.php?search=#{CGI.escape(query)}&title=Special%3ASearch&go=Go"
    open(url).base_uri.to_s    
  rescue
    "No results found"
  end

  def execute(m, query)
    m.reply(wiki(query))
  end
end
