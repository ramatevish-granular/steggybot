require 'cinch'
require 'yaml'

class Ping
  include Cinch::Plugin

  @help_hash = {
    :groups => "Usage: !groups",
    :members => "Usage: !members group",
    :ping => 'Usage: !ping group',
    :addping => "Usage: !addping group name",
    :removeping => "Usage: !removeping group name"
  }

  listen_to :channel
  match /allgroups/i,  method: :list_all_groups
  match /members (.*)/i,  method: :list_members
  match /ping (.*)/i,  method: :ping
  match /addping (.*) (.*)/i,  method: :add
  match /removeping (.*) (.*)/i,  method: :remove

  def initialize(*args)
    super
    @ping_file = config[:ping]
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
    m.reply(members_of[group].map { |name| deform(name) }.join(', '))
  end

  def ping(m, group)
    members_of = load_groups
    m.reply(members_of[group].join(', '))
  end

  def add(m, group, name)
    all_groups = load_groups
    members_of = all_groups

    if all_groups.has_key?(group)
      members_of[group].push(name)
    else
      members_of[group] = [name]
    end

    write_to_file(all_groups)

    m.reply("Added #{name} to #{group}")
  end

  def remove(m, group, name)
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
