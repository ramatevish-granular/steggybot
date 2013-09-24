require 'cinch'
require './lib/markov'

require 'thread'

class YaBish
  include Cinch::Plugin

  @help_string = "YaBish listens in the channel, waiting for someone to say its name, and then replying with a markov-generated sentence"
  listen_to :channel

  def initialize(*)
    super
    @mutex = Mutex.new
    @db = config[:db]
    @markov = Markov.from_file(@db)
  end

  def listen(m)
    # reply only if steggybot's name or `ya bish` is mentioned
    if m.message =~ /\b(#{m.bot.nick}|ya\s+bish)/
      m.reply @markov.generate_sentence($`)
    else
      # learn from every message and save every once in a while
      @mutex.synchronize {
        @markov.train!(m.message)
        @markov.save(@db)
      }
    end
  end
end
