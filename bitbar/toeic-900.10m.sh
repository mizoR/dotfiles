#!/usr/bin/env sh

export PATH=$HOME/bin:/usr/local/bin:$PATH

curl -s https://twitter.com/TOEIC_990 | \
pup 'p.tweet-text json{}' |             \
ruby -Ku -rjson -e '
  data = JSON.parse(STDIN.read)

  objects = data.map {|o|
    line = o["text"].to_s

    word        = line[/^([a-zA-Z ]+) \//, 1]
    description = line[/^[a-zA-Z ]+ \/.+\/.(.+)$/, 1]

    { word: word, description: description }
  }.reject { |h| h[:word].to_s.empty? }

  objects.shuffle.each.with_index do |object, i|
    word, description = object.values_at(:word, :description)

    if i == 0
      puts "🗽#{word}"
      puts "---"
    end

    puts "#{word} --- #{description} | href=https://eow.alc.co.jp/search?q=#{word}"
  end
'
