require 'cinch'
require 'levenshtein'

class Vote
  attr_accessor :name, :value
  def initialize(name, value)
    @name = name
    @value = value
  end
end

class Request
  attr_accessor :name, :votes
  def get_total
    return 0 if @votes.empty?
    @votes.map(&:value).reduce(&:+)
  end
  def initialize(name)
    @name = name
    @votes = []
  end
end

class FeatureRequest
  include Cinch::Plugin
  
  match /(add)? request (.+)/i, method: :add_request
  match /list/i, method:  :list_requests
  match /vote (.+)/i, method: :vote_request
  
  def initialize(*args)
    super
    @requests = config[:requests]
  end


  def open_requests(&block)
    # special case for when the file is empty
    File.open(@requests, "a+") do |f|
      f.write(YAML.dump({})) if f.read == ""
    end
    File.open(@requests, "r") do |file|
      output = YAML.load(file.read)
      result = block.call(output)
    end
  end

  def vote_request(m, request)
    vote_regex = /([+-])1?/
    plus_or_minus = request[vote_regex]
    return m.reply("This syntax is incorrect. A correctly formatted vote looks like:
!vote +1 foo") if plus_or_minus.nil?
    is_positive = (plus_or_minus.slice(0,1) == "+")
    delta = is_positive ? 1 : -1
    nick = m.user.nick
    response = "Steggybot had an error :("
    open_requests do |requests|
      # Oh god this is so ugly. Production fix pending a better way
      request = request.split(vote_regex).last.strip
      # TODO: do levenshtein here
      this_request = requests[request] 
      return m.reply "No such request #{request}" if this_request.nil?

      if this_request.votes.map(&:name).include? nick
        response = "#{nick}: Can't vote for something you already voted for!"
      else
        this_request.votes << Vote.new(nick, delta)
        response = "#{nick}: Added vote for #{request} successfully. Current value is #{this_request.get_total}"
      end
      result_file = File.open(@requests, "w+") { |f| f.write(YAML.dump(requests)) }
      m.reply(response)
    end
    
  end

  def list_requests(m)
    requests = {}
    response = []
    open_requests do |requests|
      requests = requests.sort {|(name, request), (name2, request2)| request.get_total <=> request2.get_total}.reverse.slice(0, 5)
      requests.each_with_index do |(name, request), index|
        response << "#{index}: #{name} - Total votes :#{request.get_total}"
      end
      m.reply(response.join("\n"))
    end
  end

  def add_request(m, request)
    response = "Steggybot had an error :("
    open_requests do |requests|
      if requests[request.downcase]
        # if the request already exists
        response = "#{request} already exists"
      else
        # if it does not already exist
        requests[request.downcase] = Request.new(request)
        # So, this is pretty trivially not threadsafe. And steggybot can be multithreaded. But the chances _are_ pretty low
        result_file = File.open(@requests, "w+") { |f| f.write(YAML.dump(requests)) }
        response = "Successfully added #{request}"
      end
    end
    m.reply "#{m.user.nick}: #{response}"
  end

end
