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
    fc = pargs[1]
    # add it to the list
    fcs = load_data || {}

    if fcs[username.downcase] && (fcs[username.downcase][:added_by] == username.downcase)
      if m.user.nick.downcase == username.downcase
        fcs[username.downcase] = {:fc => fc, :added_by => m.user.nick.downcase, :updated_at => DateTime.now}
      else
        m.reply "#{m.user.nick}: Can't override a user's self-definition."
        return
      end
    else
      fcs[username.downcase] = {:fc => fc, :added_by => m.user.nick.downcase, :updated_at => DateTime.now}
    end

    # write it to the file
    output = File.new(@pddata, 'w')
    output.puts YAML.dump(fcs)
    output.close

    m.reply "#{m.user.nick}: #{mangle(username)} successfully added as '#{fc}'."
  end

  def pazudora_remove(m, args)
    pargs = args.split
    username = pargs[0]
    fcs = load_data || {}

    unless fcs[username]
      m.reply "#{m.user.nick}: #{mangle(username)} not in friend code list."
      return
    end

    if (m.user.nick.downcase == username.downcase) || (m.user.nick.downcase == fcs[username][:added_by])
      fcs.delete(username)
      # write it to the file
      output = File.new(@pddata, 'w')
      output.puts YAML.dump(fcs)
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
      m.reply "#{m.user.nick}: #{mangle(username)}'s friend code is #{load_data[username.downcase][:fc]}"
    end
  end
    
  def pazudora_list(m,args)
    fcs = load_data || {}
    fcs.keys.each_slice(3) { |users| 
      r = "#{m.user.nick}: "
      users.each{ |user| r=r+"#{mangle(user)}:#{fcs[user][:fc]} " }
      m.reply r
    }
  end

  protected

  def mangle(s)
    s.chop + "." + s[-1]
  end

  def load_data
    datafile = File.new(@pddata, 'r')
    fcs = YAML.load(datafile.read)
    datafile.close
    return fcs
  end
end
