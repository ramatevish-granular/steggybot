require 'strscan'

class Array
  def sum
    inject(0, &:+)
  end unless [].respond_to? :sum
end

class Markov
  class Bucket < Hash
    def initialize(*)
      super
      @total = values.sum
    end

    def <<(word)
      @total += 1
      self[word] ||= 0
      self[word] += 1
    end

    def sample
      idx = rand(@total)
      counter = 0
      each do |k, v|
        counter += v
        return k if counter > idx
      end
    end
  end

  def self.train!(sentences, opts={})
    empty(opts[:depth]).train_all!(sentences)
  end

  def self.from_file(fname)
    lines = File.readlines(fname).each(&:chomp!)
    depth = Integer(lines.shift)
    train!(lines, :depth => depth)
  end

  def save(fname)
    File.open(fname, 'w') do |f|
      f.puts depth
      sentences.each { |s| f.puts s }
    end

    self
  end

  attr_reader :links, :inits, :sentences, :depth
  def initialize(links, inits, sentences, depth)
    @sentences = sentences
    @links = links
    @inits = inits
    @depth = depth
  end

  def inspect
    "#<Markov #{object_id} depth:#{depth} size:#{links.size}>"
  end

  def self.empty(depth)
    new({}, [], [], depth)
  end

  END_PUNC = /[?!.]/
  PUNC = /[:,="+-]/
  URL = %r(\w+://\S*)
  WORD = /[0-9a-z'-]+/i

  def tokenize(string, &b)
    return enum_for :tokenize, string unless b
    string.scan %r(#{END_PUNC}|#{PUNC}|#{URL}|#{WORD})o, &b
    yield nil
  end

  def train!(sentence)
    add_sentence! sentence

    tokens = tokenize(sentence)

    tokens.each_cons(depth+1) do |(*pattern, word)|
      add_link!(pattern, word)
    end

    add_init! tokens.first(depth)

    self
  end

  def train_all!(sentences=[])
    sentences.each(&method(:train!))
    self
  end

  def load_file(fname)
    File.readlines(fname).each(&method(:load_string)); nil
  end

  def load_lines(str)
    str.split("\n").each(&method(:load_string)); nil
  end

  def add_link!(pattern, word)
    (links[pattern.map(&:downcase)] ||= Bucket.new) << word
  end

  def add_init!(pattern)
    inits << pattern.compact
  end

  def add_sentence!(sentence)
    sentences << sentence
  end

  def random_init(seed=[])
    seed = seed.dup
    seed.concat inits.sample while seed.size < depth
    seed
  end

  def sample(pattern)
    pattern = pattern.map(&:downcase)
    return nil unless links.include? pattern

    links[pattern].sample
  end

  MAX_SENTENCE_WORDS = 50
  def generate_sentence(seed="")
    seed = tokenize(seed).to_a
    seed.pop
    out = random_init(seed)

    loop do
      p :loop => out
      break if END_PUNC === out.last
      break if out.size >= MAX_SENTENCE_WORDS
      next_word = sample(out[-depth..-1])
      break unless next_word
      break if next_word.nil?
      out << next_word
    end

    p :tokens => out

    detokenize(out)
  end

  def detokenize(tokens)
    out = ""
    tokens.each do |tok|
      case tok
      when /^(#{END_PUNC}|#{PUNC})/o
        out << tok
      else
        out << " #{tok}"
      end
    end

    if out[0] == ' '
      out[1..-1]
    else
      out
    end
  end

  def self.load_from(fname)
    db = Marshal.load(File.read(fname))
    new(db)
  end

  def save_to(fname)
    File.open(fname, 'w') { |f| f << Marshal.dump(@db) }
  end
end
