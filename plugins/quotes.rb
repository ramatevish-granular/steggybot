require 'cinch'
require 'yaml'

class Quotes
  include Cinch::Plugin
  @help_hash = {
      :addquote => "Usage: !addquote Quote
Example: !addquote \"That steggybot sure is something\"",
      :quote => "Usage !quote [search]
Example: !quote whunt",
      :fortune => "Same as quote",
    :deletequote => "Usage: !deletequote $QUOTE_ID
Example: !deletequote 1"
    }
  match /addquote (.+)/i, method: :addquote
  match /quote (.+)/i, method: :quote
  match /fortune/i, method: :quote
  match /deletequote ([0-9]+)/i, method: :delete_quote

  def initialize(*args)
    super

    @quotes_file = config[:quotes_file]
  end

  def addquote(m, quote)
    # make the quote
    new_quote = { "quote" => quote, "added_by" => m.user.nick, "created_at" => Time.now, "deleted" => false }

    # add it to the list
    existing_quotes = get_quotes || []
    new_quote_id = existing_quotes.last["id"].to_i + 1
    new_quote["id"] = new_quote_id
    existing_quotes << new_quote
    
    # write it to the file
    output = File.new(@quotes_file, 'w')
    output.puts YAML.dump(existing_quotes)
    output.close

    # send reply that quote was added
    m.reply "#{m.user.nick}: Quote successfully added as ##{new_quote_id}."
    m.reply "And now for your daily fortune:"
    m.reply quote_text(active_quotes.sample)
  end

  def delete_quote(m, id)
    existing_quotes = get_quotes || []
    to_delete = existing_quotes.find do |quote|
      quote["id"].to_i == id.to_i && quote["added_by"] == m.user.nick
    end

    existing_quotes.delete(to_delete)
    output = File.new(@quotes_file, 'w')
    output.puts YAML.dump(existing_quotes)
    output.close

    m.reply "#{m.user.nick}: Quote # #{id} successfully deleted."
    m.reply "Text was #{quote_text(to_delete)}"
  end

  def quote(m, search = nil)
    quotes = active_quotes
    if search.nil? # we are pulling random
      quote = quotes.sample
      m.reply "#{m.user.nick}: #{quote_text(quote)}"
    elsif search.to_i != 0 # then we are searching by id
      quote = quotes.find{|q| q["id"] == search.to_i }
      if quote.nil?
        m.reply "#{m.user.nick}: No quotes found."
      else
        m.reply "#{m.user.nick}: #{quote_text(quote)}"
      end
    else
      quotes.keep_if{ |q| q["quote"].downcase.include?(search.downcase) }
      if quotes.empty?
        m.reply "#{m.user.nick}: No quotes found."
      else
        quote = quotes.sample
        m.reply "#{m.user.nick}: #{quote_text(quote)}"
        m.reply "The search term also matched on quote IDs: #{quotes.map{|q| q["id"]}.join(", ")}" if quotes.size > 1
      end
    end
  end

  #--------------------------------------------------------------------------------
  # Protected
  #--------------------------------------------------------------------------------

  protected

  def get_quotes
    output = File.new(@quotes_file, 'r')
    quotes = YAML.load(output.read)
    output.close

    quotes
  end

  def active_quotes
   get_quotes.delete_if{ |q| q["deleted"] == true }
  end

  def quote_text(quote)
     "##{quote["id"]} (#{quote["created_at"].strftime("%m/%d/%Y %I:%M %p")}) - #{quote["quote"]}"
  end

end
