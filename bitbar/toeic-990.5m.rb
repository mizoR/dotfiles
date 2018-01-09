#!/usr/bin/env ruby

require 'open-uri'
require 'json'
require 'cgi'

ENV['PATH'] = "#{ENV['HOME']}/bin:#{ENV['PATH']}"

html = open('https://twitter.com/TOEIC_990') { |f| f.read }

source = IO.popen('pup p.tweet-text json{}', 'r+') do |io|
  io.puts html
  io.close_write
  io.read
end

data = JSON.parse(source)

objects = data.map { |o|
  line = o["text"].to_s

  word        = line[/^([a-zA-Z ]+) \//, 1]
  description = line[/^[a-zA-Z ]+ \/.+\/.(.+)$/, 1]

  word        = CGI.unescapeHTML(word)        if word
  description = CGI.unescapeHTML(description) if description

  { word: word, description: description }
}.reject { |h| h[:word].to_s.empty? }

objects.shuffle!

puts "🗽#{objects.first[:word]}"
puts "---"

objects.each.with_index do |object, i|
  word, description = object.values_at(:word, :description)

  puts "#{word} --- #{description} | href=https://eow.alc.co.jp/search?q=#{word}"

  words = description.split
    .map { |w| w[/\w+/] }
    .uniq.select { |w| w.length >= 5 }
    .sort_by(&:itself)

  words.each do |w|
    puts "-- #{w} | href=https://eow.alc.co.jp/search?q=#{w}"
  end
end
