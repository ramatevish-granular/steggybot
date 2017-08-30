require 'cinch'
require 'yaml'

class Ping
  include Cinch::Plugin

  @help_hash = {
    :group => 'To ping all members of a specific group, use: !ping group',
    :everyone => 'To ping everyone in the channel, use: !ping everyone',
    :listall => "To list all the groups in existence, use: !ping listall",
    :list => "To list all the members of a group without pinging them, use: !ping list group",
    :add => "To add a name to a group, use: !ping add name to group",
    :remove => "To remove a name from a group, use: !ping remove name from group",
    :obliterate => "To remove a group, use: !ping obliterate group"
  }

  RESERVED = ['everyone','listall']

  match /ping everyone/i,  method: :ping_everyone
  match /ping listall/i,  method: :list_all_groups
  match /ping list ([\w-]+)/i,  method: :list_members
  match /ping obliterate ([\w-]+)/i,  method: :remove_group
  match /ping add ([\w-]+) to ([\w-]+)/i,  method: :add
  match /ping remove ([\w-]+) from ([\w-]+)/i,  method: :remove
  match /ping ([\w-]+)/i,  method: :ping

  match /group everyone/i,  method: :ping_everyone
  match /group listall/i,  method: :list_all_groups
  match /group list ([\w-]+)/i,  method: :list_members
  match /group obliterate ([\w-]+)/i,  method: :remove_group
  match /group add ([\w-]+) to ([\w-]+)/i,  method: :add
  match /group remove ([\w-]+) from ([\w-]+)/i,  method: :remove
  match /group ([\w-]+)/i,  method: :ping

  def initialize(*args)
    super
    @ping_file = config[:ping]
  end

  def ping_everyone(m)
    everyone = Channel(m.channel).users.keys.reject { |user| user.is_a?(Cinch::Bot)} # everyone who's not a bot
    m.reply(everyone.map { |user| user.nick}.join(', '))
  end

  def list_all_groups(m)
    all_groups = load_groups
    if all_groups.empty?
      m.reply("There are no groups")
    else
      m.reply(all_groups.keys.join(', '))
    end
  end

  def list_members(m, group)
    all_groups = load_groups
    unless all_groups.has_key?(group)
      m.reply("Group #{group} does not exist")
    end

    # no need for empty check since we remove the group when it becomes empty
    members_of = all_groups
    m.reply("#{group} has " + members_of[group].map { |name| deform(name) }.join(', '))
  end

  def remove_group(m, group)
    all_groups = load_groups

    unless all_groups.has_key?(group)
      m.reply("Group #{group} does not exist")
      return
    end

    members = all_groups.delete(group)
    write_to_file(all_groups)

    m.reply("#{group} has been removed: " + members.join(', '))
  end

  def ping(m, group)
    members_of = load_groups
    m.reply(members_of[group].join(', '))
  end

  def add(m, name, group)
    if RESERVED.include?(group)
      m.reply("#{group} is reserved")
      return
    end

    all_groups = load_groups
    members_of = all_groups

    if all_groups.has_key?(group)
      if members_of[group].include?(name)
        m.reply("#{name} is already in #{group}")
        return
      end
      members_of[group].push(name)
    else
      members_of[group] = [name]
    end

    write_to_file(all_groups)

    m.reply("Added #{name} to #{group}")
  end

  def remove(m, name, group)
    all_groups = load_groups

    unless all_groups.has_key?(group)
      m.reply("Group #{group} does not exist")
      return
    end

    members_of = all_groups

    unless members_of[group].include?(name)
      m.reply("#{name} is not part of #{group}")
      return
    end

    members_of[group].delete(name)

    if members_of[group].empty?
      all_groups.delete(group)
    end

    write_to_file(all_groups)

    m.reply("Removed #{name} from #{group}")
  end

  protected

  def load_groups
    output = File.new(@ping_file, 'r')
    groups = YAML.load(output.read)
    output.close

    groups
  rescue
    {}
  end

  def write_to_file(groups)
    output = File.new(@ping_file, 'w')
    output.puts YAML.dump(groups)
    output.close
  end

  def deform(string)
    "#{string[0]}.#{string[1..-1]}"
  end
end
