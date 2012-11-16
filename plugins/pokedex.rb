# -*- coding: utf-8 -*-
require 'cinch'
require 'nokogiri'
require 'open-uri'
require 'levenshtein'

class Pokedex
  include Cinch::Plugin
  match /pokedex (.+)/

  def get_list_of_pokemon
    list_of_pokemon = Nokogiri::HTML(open("http://en.wikipedia.org/wiki/List_of_Pok%C3%A9mon"))
    list_of_pokemon = list_of_pokemon.css("table > tr > td > a")
    # Remove 3 because othewise we get:
    # nil
    # #<Nokogiri::XML::Attr:0x16f7b64 name="title" value="Pokémon (video game series)">
    # #<Nokogiri::XML::Attr:0xd0b6c8 name="title" value="Pokémon Red and Blue">

    list_of_pokemon = list_of_pokemon.slice(0, list_of_pokemon.length - 3).
      map{|pokemon_entry| pokemon_entry.
      attributes["title"].
      # Wiki tries to disambiguate, which well, kinda sucks for distance calculations
      value.gsub(/\(Pokémon\)/, "")}
  end

  def execute(m, pokemon)
    list_of_pokemon = get_list_of_pokemon
    closest_candidate = list_of_pokemon[list_of_pokemon.map{ |this_pokemon| Levenshtein.distance(this_pokemon, pokemon)}.each_with_index.min.last]
    m.reply(get_pokedex_entries(closest_candidate).sample, true)
  end

  def get_pokedex_entries(pokemon_name)
    file = open("http://bulbapedia.bulbagarden.net/wiki/#{pokemon_name}")
    lines = file.readlines
    # Sucks to pick it out this way, but well, yeah
    candidate_lines = lines.select{|line| line.include? "border-radius: 10px; -moz-border-radius: 10px; -webkit-border-radius: 10px; -khtml-border-radius: 10px; -icab-border-radius: 10px; -o-border-radius: 10px; background: #FFFFFF; border: 1px solid"}
    candidate_without_templates = candidate_lines.select {|line| ! line.include? "{{{"}
    candidate_without_templates.map {|line| line.gsub(/<.*>/, "").strip}
  end


  def get_list_of_pokemon
    list_of_pokemon = Nokogiri::HTML(open("http://en.wikipedia.org/wiki/List_of_Pok%C3%A9mon"))
    list_of_pokemon = list_of_pokemon.css("table > tr > td > a")
    # Remove 3 because othewise we get:
    # nil
    # #<Nokogiri::XML::Attr:0x16f7b64 name="title" value="Pokémon (video game series)">
    # #<Nokogiri::XML::Attr:0xd0b6c8 name="title" value="Pokémon Red and Blue">

    list_of_pokemon = list_of_pokemon.slice(0, list_of_pokemon.length - 3).
      map{|pokemon_entry| pokemon_entry.
      attributes["title"].
      # Wiki tries to disambiguate, which well, kinda sucks for distance calculations
      value.gsub(/\(Pokémon\)/, "")}
 end
end
