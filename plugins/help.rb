require 'cinch'

class Help
  include Cinch::Plugin
  match /help( \w+)?(.*)?/i, method: :help

  def initialize(*args)
    super
    @plugin_classes = @bot.plugins.map(&:class)
    @plugin_classes.each do |klass|
      klass.class_eval do
        def self.help_hash; @help_hash; end
        def self.help_string; @help_string; end
      end
    end
    @plugin_hash = Hash[(@plugin_classes.map(&:to_s).map(&:downcase).zip(@plugin_classes))]
  end

  def self.help_method(*args)
    "This is the Help module, which lets you ask for help information from other plugins.
As a note, you have to put your help in help_method, to avoid colliding with the vastly inferior help setup that is included with Cinch"
  end

  def help(m, plugin = nil, extra = nil)
    if plugin.nil?
      m.reply("What would you like help about? the following plugins are activated: #{@plugin_classes}")
      return
    end
    extra = extra.strip unless extra.nil?
    plugin = plugin.downcase.strip
    if @plugin_hash.keys.include? plugin
      plugin_class = @plugin_hash[plugin]
      # If the class defines a help method, defer to that
      if plugin_class.singleton_methods.include? :help_method
        m.reply(@plugin_hash[plugin].send(:help_method, extra))
        return
      # If the class doesn't have a help method, grab the help_hash and do the normal thing for it
      elsif plugin_class.help_hash != nil
        help_hash = plugin_class.help_hash
        if help_hash.keys.include? extra.to_sym
          m.reply(help_hash[extra.to_sym])
        else
          m.reply("This is the #{plugin_class} module. For more information on how to use, try !help #{plugin_class} {#{help_hash.keys.join","}}")
        end
        # Some modules simply listen into the channel, and so have no API. So, while it makes sense to have a help string describing their function, they can't be easily described in the same way as most with a help_hash
      elsif plugin_class.help_string != nil
        m.reply(plugin_class.help_string)
      else
        #It's a valid plugin, but with no help info.
        m.reply("The module #{plugin_class} has no help info associated with it. Luckily, it is open source! If you are knowledgeable about #{plugin_class}, please go to https://github.com/mjsteger/steggybot and contribute")
      end
    else
      m.reply("The plugin #{plugin} is not a valid plugin to ask help on. Please select from #{@plugin_classes}")
    end
  end
end
