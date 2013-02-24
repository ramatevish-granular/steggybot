require 'cinch'
require 'yaml'

class PlusPlus
  include Cinch::Plugin

  listen_to :channel
  match /persons_feelings (\w+)/i, method: :lookup_feelings
  match /person (\w+)/i, method: :lookup

  def lookup(m, name)
    values = plusplus_file
    values = values.keys.map { |key| values[key] if values[key][name] > 0 }.compact
    p "values: #{values}"
    result = values.empty? ? "no results" : values
    m.reply(result)
  end

  def lookup_feelings(m, name)
    values = plusplus_file
    result = (values.keys.include? name) ? values[name] : "no results"
    m.reply(result)
  end

  def initialize(*args)
    super
    @plusplus_file = config[:plusplus]
  end

  def listen(m)
    plusplus = %r{(?<to>(\w+))\+\+}.match m.message
    add(m.user.nick, plusplus[:to]) if plusplus
  end

  def plusplus_file()
    file = File.new(@plusplus_file, 'r')
    values = YAML.load(file.read)
    file.close
    values
  end

  def add(from, to)
    p "from is #{from}, to is #{to}"
    values = plusplus_file || {}
    p "values is #{values}"
    froms_feelings = (values.keys.include? from) ? values[from] : Hash.new { |hash, key| hash[key] = 0 }
    p "now is is #{froms_feelings}"
    froms_feelings[to] += 1
    p "now is is #{froms_feelings}"
    values[from] = froms_feelings
    p "now is is #{froms_feelings}"
    File.open(@plusplus_file, 'w') { |f| f.write (YAML.dump values) }
  end
end

