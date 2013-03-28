require 'cinch'

class Pazudora
  include Cinch::Plugin
  
  listen_to :channel
  match /pazudora ([\w-]+) *(.+)*/i, method: :pazudora
  match /stupidpuzzledragonbullshit ([\w-]+) *(.+)*/i, method: :pazudora
  match /stupiddragonpuzzlebullshit ([\w-]+) *(.+)*/i, method: :pazudora
  match /p&d ([\w-]+) *(.+)*/i, method: :pazudora
  match /pad ([\w-]+) *(.+)*/i, method: :pazudora
  match /puzzlemon ([\w-]+) *(.+)*/i, method: :pazudora
  
  def initialize(*args)
    super
    @pddata = config[:pddata]
  end
  
  def pazudora (m, cmd, args)
    subr = cmd.downcase.chomp
    begin
      if args
        self.send("pazudora_#{subr}", m, args)
      else
        self.send("pazudora_#{subr}", m, "")
      end
    rescue NoMethodError
      puts "Pazudora called with invalid command #{subr}."
    end
  end
  
  def pazudora_add (m, args)
    pargs = args.split
    username = pargs[0]
    friend_code = pargs[1]
    # add it to the list
    friend_codes = load_data || {}
    if friend_code =~ /[0-9]{9}/
      friend_code = friend_code.reverse.gsub(%r{([0-9]{3}(?=([0-9])))},".").reverse
      
      if friend_codes[username.downcase] && (friend_codes[username.downcase][:added_by] == username.downcase)
        if m.user.nick.downcase == username.downcase
          friend_codes[username.downcase] = {:friend_code => friend_code, :added_by => m.user.nick.downcase, :updated_at => DateTime.now}
        else
          m.reply "#{m.user.nick}: Can't override a user's self-definition."
          return
        end
      else
        friend_codes[username.downcase] = {:friend_code => friend_code, :added_by => m.user.nick.downcase, :updated_at => DateTime.now}
      end
      
      # write it to the file
      output = File.new(@pddata, 'w')
      output.puts YAML.dump(friend_codes)
      output.close
      
      m.reply "#{m.user.nick}: #{mangle(username)} successfully added as '#{friend_code}'."
    end
  end
  
  def pazudora_remove(m, args)
    pargs = args.split
    username = pargs[0]
    friend_codes = load_data || {}
    
    if ! friend_codes[username]
      m.reply "#{m.user.nick}: #{mangle(username)} not in friend code list."
      return
    end
    
    if (m.user.nick.downcase == username.downcase) || (m.user.nick.downcase == friend_codes[username][:added_by])
      friend_codes.delete(username)
      # write it to the file
      output = File.new(@pddata, 'w')
      output.puts YAML.dump(friend_codes)
      output.close
      
      m.reply "#{m.user.nick}: #{mangle(username)} removed from friend code list."
    else
      m.reply "#{m.user.nick}: Only the identity creator or subject can remove a friend code from the list."
    end
  end
  
  def pazudora_who(m,args)
    pargs = args.split
    username = pargs[0]
    if load_data[username.downcase]
      m.reply "#{m.user.nick}: #{mangle(username)}'s friend code is #{load_data[username.downcase][:friend_code]}"
    end
  end
  
  def pazudora_list(m,args)
    friend_codes = load_data || {}
    friend_codes.keys.each_slice(3) { |users| 
      r = "#{m.user.nick}: "
      users.each{ |user| r=r+"#{mangle(user)}:#{friend_codes[user][:friend_code]} " }
      m.reply r
    }
  end
  
  def pazudora_group(m,args)
    pargs = args.split
    username = pargs[0]
    if load_data[username.downcase]
      friend_code = load_data[username.downcase][:friend_code]
      group = (Integer(friend_code.split(",")[0][2]) % 5 + 65).chr
      m.reply "#{m.user.nick}: #{mangle(username)}'s group is #{group}"
    else
      m.reply "#{m.user.nick}: #{mangle(username)}'s friend code is not listed. Please use the add command to add it."
    end
  end
  
  protected
  
  def mangle(s)
    s.chop + "." + s[-1]
  end
  
  def load_data
    datafile = File.new(@pddata, 'r')
    friend_codes = YAML.load(datafile.read)
    datafile.close
    return friend_codes
  end
end

