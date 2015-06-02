require 'cinch'
require 'nokogiri'
require 'open-uri'
require 'youtube_it'

class Youtube
  include Cinch::Plugin
  listen_to :channel

  def listen(m)
    urls = URI.extract(m.message, "http")
    urls += URI.extract(m.message, "https")
    urls = urls.select{|url| url.include? "youtube.com"}
    page_info = urls.map{|url| get_page_info(url)}.compact
    unless page_info.empty?
      m.reply page_info.join("\n")
    end
  end

  def get_page_info(url)
    page = Nokogiri::HTML(open(url))
    video_id = url.match(/\?v=(.*)/).captures.first
    client = YouTubeIt::Client.new
    # comments = client.comments(video_id).slice(0,3).map {|x| "#{x.author.name} - #{x.content}"}
    return_string = "Title: " + page.title + " With count: " + client.video_by(video_id).view_count.to_s 
    #      " - Top Comments: \t" + comments.join("\t")
  end
end
