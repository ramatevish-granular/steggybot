require 'spec_helper'
require File.dirname(__FILE__) + "/../ya_bish.rb"

describe YaBish do

  before(:all) do
    @ya_bish = YaBish.new(bot)
  end

  it "should reply if it hears the name 'steggybot'" do
    ["steggybotbotbot", "hi steggybot", 
     "and then someone mentioned steggybottttttTTTTtt and all was well",
     "steggybot is active right now"].each do |m|
      @message = mock_message(:message => m)
      @message.should_receive(:reply) do |rep|
        rep.end_with?("ya bish").should be_true
      end
        
      @ya_bish.listen(@message)
    end
  end
  
  it "should reply if it hears the phrase 'ya bish'" do
    ["ya bish is a dumb phrase", "hi all ya bishes", 
     "From nine to five I know its vacant, ya bish",
     "something here ya bish something else"].each do |m|
      @message = mock_message(:message => m)
      @message.should_receive(:reply) do |rep|
        rep.end_with?("ya bish").should be_true
      end
        
      @ya_bish.listen(@message)
    end
  end
  
  it "should not reply if it hears a mundane phrase" do
    ["hey guys wat's up", "i like cats", 
     "oh my god no one cares about your puzzlemons :<",
     "gosh testing is so cool i wish everyone was this cool"].each do |m|
      @message = mock_message(:message => m)
      @message.should_not_receive(:reply)
      @ya_bish.listen(@message)
    end
  end
  
  it "should not reply if its name or ya bish are not all-lowercase" do
      ["STEGGYBOT WHERE ARE YOU", "yA bishes sometingsomething", 
     "ya bisH and Ya bish and ya Bish blah",
     "steggy bot and Steggybot are too cool for da ~real~ one"].each do |m|
      @message = mock_message(:message => m)
      @message.should_not_receive(:reply)
      @ya_bish.listen(@message)
    end
  end

end
