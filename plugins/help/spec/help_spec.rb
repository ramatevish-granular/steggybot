require 'spec_helper'
require File.dirname(__FILE__) + "/../help.rb"

describe Help do

  class HelpfulClass
    include Cinch::Plugin
    @help_string = "I am a helpful string!"
    @help_hash = {
      :greet => "I am a helpful greeting",
      :more_greet => "I am an even more helpful greeting",
    }
  end
  
  class BoringClass
    include Cinch::Plugin
    @help_string = "I don't have a helpful hash."
  end
  
  class HashyClass
    include Cinch::Plugin
    @help_hash = {
      :greet => "Hello~",
      :goodbye => "Bye~",
      :class => "I am a class that has a hash!"
    }
  end
  
  before(:each) do
    Cinch::IRC.any_instance.stub(:connect).and_return(false)
    configured_bot = bot(:plugins => [HelpfulClass, BoringClass, HashyClass, Help])
    
    #Must be started because that's where "register_plugins" is located and we need the
    #plugin that was initialized with all the other ones
    configured_bot.start
    @help_plugin = configured_bot.plugins.find{|x| x.class == Help}
  end

  it "should initialize with knowledge of its helped classes" do
    @message = mock_message()
    
    @message.should_receive(:reply) do |rep|
      ["HelpfulClass", "BoringClass", "HashyClass"].each do |name|
        rep.should include(name)
      end
    end
    
    @help_plugin.help(@message)
  end
  
  it "should preferentially defer to help_hash even when help_string is given" do
    [["HelpfulClass", /For more information on how to use/],
     ["BoringClass", "I don't have a helpful hash."],
     ["HashyClass", /For more information on how to use/]].each do |plugin_name, reply_text|
      @message = mock_message()
      @message.should_receive(:reply).with(reply_text)
      @help_plugin.help(@message, plugin_name)
    end
  end
  
  it "should query options from the help_hash" do
     [["HelpfulClass", "invalid_command", /For more information on how to use/],
     ["HelpfulClass", "greet", "I am a helpful greeting"],
     ["BoringClass", "invalid_command", "I don't have a helpful hash."],
     ["HashyClass", "goodbye", "Bye~"]
     ].each do |plugin_name, command, reply_text|
      @message = mock_message()
      @message.should_receive(:reply).with(reply_text)
      @help_plugin.help(@message, plugin_name, command)
    end
  end
end
