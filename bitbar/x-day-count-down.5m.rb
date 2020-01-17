#!/usr/bin/env ruby
require 'erb'
require 'time'

module BitBar
  class INIFile
    Error = Class.new(StandardError)

    INIFileNotFound = Class.new(Error)

    SectionNotFound = Class.new(Error)

    def self.load(file = "#{ENV['HOME']}/.bitbarrc")
      raise INIFileNotFound if !File.exist?(file)

      parse(open(file) { |f| f.read })
    end

    def self.parse(source)
      # XXX: This implementation isn't correct, but will work in most cases.
      #      (Probably `StringScanner` will make code correct and clean.)
      sections = {}

      section = nil

      source.each_line do |line|
        if line =~ /^ *;/
          # comment
          next
        end

        if line =~ /^\[(.+)\]$/
          section = sections[$1.to_sym] = {}
          next
        end

        next unless section

        if line =~ /(.+)=(.+)/
          name  = $1.strip.to_sym
          value = $2.strip

          section[name] = value[/^"(.*)"$/, 1] || value[/^'(.*)'$/, 1] || value
          next
        end
      end

      new(sections: sections)
    end

    def initialize(sections:)
      @sections = sections
    end

    def fetch(name)
      @sections.fetch(name.to_sym)
    rescue KeyError
      raise SectionNotFound
    end
  end

  module XDayCountDown
    ConfigurationError = Class.new(StandardError)

    class XDay < Struct.new(:key, :label, :time)
      def self.from(db:)
        xdays = []

        db.each do |key, label|
          matches = key.to_s.match(/xday_label_(.+)$/)
          next unless matches
          key = matches[1]
          time = Time.parse(db[:"xday_time_#{key}"])
          xdays << XDay.new(key, label, time)
        end

        xdays
      end

      def days
        require 'date'
        (time.to_date - Date.today).to_i
      end
    end

    class View
      TEMPLATE = <<-EOT.gsub(/^ */, '')
        <%= @xdays[0].label %><%= @xdays[0].days  %> days
        ---
        <% @xdays.each do |xday| -%>
        <%= xday.label %><%= xday.days %> days
        <% end -%>
      EOT

      def initialize(xdays:)
        @xdays = xdays
      end

      def render
        puts ERB.new(TEMPLATE, nil, '-').result(binding)
      end
    end

    class App
      DEFAULT_CONFIG = {}

      def initialize(config = {})
        @config = cast_config(DEFAULT_CONFIG.merge(config))
      end

      def run
        xdays = XDay.from(db: @config)

        View.new(xdays: xdays).render
      end

      private

      def cast_config(config)
        if config.empty?
          raise ConfigurationError, 'GitHub username is not given.'
        end

        config
      end
    end
  end
end

if __FILE__ == $0
  begin
    config = BitBar::INIFile.load.fetch(:'xday_count_down')

    BitBar::XDayCountDown::App.new(config).run
  rescue BitBar::INIFile::Error
    puts <<-EOM.gsub(/^ */, '')
      ⚠️
      ---
      To setup, create or edit your ~/.bitbarrc file with a new section:
      |
      ;# ~/.bitbarrc
      [xday_count_down]
      xday_label_my_daughter_independence_day = "My daughter's independence: "
      xday_time_my_daughter_independence_day  = "2028-03-30T00:00:00+09:00"
    EOM
  rescue BitBar::XDayCountDown::ConfigurationError => e
    puts <<-EOM.gsub(/^ */, '')
      ⚠️
      ---
    #{e.message}
    EOM
  end
end
