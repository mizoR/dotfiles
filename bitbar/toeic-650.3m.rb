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

words = JSON.parse(source)

words.map! { |o| CGI.unescapeHTML(o["text"].to_s) }

words.map! { |o| o.split("\n") }

words.map! { |lines|
  if lines[0].to_s =~ /\A([a-zA-Z ]+)(\[.+\])?(.+)$/
    text      = $1&.strip
    pronounce = $2&.strip
    meaning   = $3&.strip

    e, j = lines[-2] =~ /^[\!-\~\s]+$/ ? [-2, -1] : [-3, -2]

    params = {
      text:      text,
      pronounce: pronounce,
      meaning:   meaning,
      english:   lines[e],
      japanese:  lines[j],
    }

    OpenStruct.new(params)
  end
}

words.select!(&:itself)

words.shuffle!

pstore = File.join(
  __dir__,
  'db',
  File.basename(__FILE__).sub(/\.rb$/, '.pstore')
)

db = PStore.new(pstore)

db.transaction do
  db_words = db.fetch(:words, {})

  words.each do |word|
    db_words[word.text] = word.to_h
  end

  db[:words] = db_words
end

word = words.first

puts "🗽#{word.text}"

puts '---'

puts words.map { |o|
  <<-EOS.gsub(/^ */, '')
    #{o.text} --- #{o.meaning} | href=https://eow.alc.co.jp/search?q=#{URI.escape(o.text)}
    -- #{o.english} | color=grey
    -- #{o.japanese} | color=grey
  EOS
}

db.transaction do
  puts '---'
  puts 'Others'

  db[:words].sort_by { |k, _| k }.map { |_, h| OpenStruct.new(h) }.map do |o|
    puts <<-EOS.gsub(/^ */, '')
      -- #{o.text} --- #{o.meaning} | href=https://eow.alc.co.jp/search?q=#{URI.escape(o.text)}
      ---- #{o.english} | color=grey
      ---- #{o.japanese} | color=grey
    EOS
  end
end
