def mock_message(opts={})
  m = mock()
  
  m.should_receive(:message).and_return(opts[:message]) if opts[:message]
  return m
end

def bot(opts={})
  cinch_bot = Cinch::Bot.new do
    configure do |c|
      c.nick = "steggybot_testbot"
      c.server = nil
      c.channels = []
      c.plugins.plugins = opts[:plugins] if opts[:plugins]
      c.reconnect = false
    end
  end

  cinch_bot
end
