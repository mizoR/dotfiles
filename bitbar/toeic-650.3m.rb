#!/usr/bin/env ruby

require 'ostruct'
require 'open-uri'
require 'json'
require 'cgi'
require 'pstore'

ENV['PATH'] = "#{ENV['HOME']}/bin:#{ENV['PATH']}"

html = open('https://twitter.com/TOEIC6500') { |f| f.read }

source = IO.popen('pup p.tweet-text json{}', 'r+') do |io|
  io.puts html
  io.close_write
  io.read
end

objects = JSON.parse(source)

objects.map! { |o| CGI.unescapeHTML(o["text"].to_s) }

objects.map! { |o| o.split("\n") }

objects.map! { |lines|
  if lines[0].to_s =~ /\A([a-zA-Z ]+)(\[.+\])?(.+)$/
    word      = $1&.strip
    pronounce = $2&.strip
    meaning   = $3&.strip

    e, j = lines[-2] =~ /^[\!-\~\s]+$/ ? [-2, -1] : [-3, -2]

    params = {
      word:      word,
      pronounce: pronounce,
      meaning:   meaning,
      english:   lines[e],
      japanese:  lines[j],
    }

    OpenStruct.new(params)
  end
}

objects.select!(&:itself)

objects.shuffle!

pstore = File.join(
  __dir__,
  'db',
  File.basename(__FILE__).sub(/\.rb$/, '.pstore')
)

db = PStore.new(pstore)

db.transaction do
  db_objects = db.fetch(:objects, {})

  objects.each do |object|
    db_objects[object.word] = object.to_h
  end

  db[:objects] = db_objects
end

object = objects.first

puts "🗽#{object.word}"

puts '---'

puts objects.map { |o|
  <<-EOS.gsub(/^ */, '')
    #{o.word} --- #{o.meaning} | href=https://eow.alc.co.jp/search?q=#{URI.escape(o.word)}
    -- #{o.english} | color=grey
    -- #{o.japanese} | color=grey
  EOS
}

db.transaction do
  puts '---'
  puts 'Others'

  db[:objects].sort_by { |k, _| k }.map { |_, h| OpenStruct.new(h) }.map do |o|
    puts <<-EOS.gsub(/^ */, '')
      -- #{o.word} --- #{o.meaning} | href=https://eow.alc.co.jp/search?q=#{URI.escape(o.word)}"
      ---- #{o.english} | color=grey
      ---- #{o.japanese} | color=grey
    EOS
  end
end
