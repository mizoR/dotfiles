#!/usr/bin/env ruby
# frozen_string_literal: true

# <bitbar.title>Github Contribution</bitbar.title>
# <bitbar.version>v0.0.1</bitbar.version>
# <bitbar.author>mizoR</bitbar.author>
# <bitbar.author.github>mizoR</bitbar.author.github>
# <bitbar.image>https://user-images.githubusercontent.com/1257116/34550684-37da7286-f156-11e7-9299-5873b6bb2fd7.png</bitbar.image>
# <bitbar.dependencies>ruby</bitbar.dependencies>
#
# To setup, create or edit your ~/.bitbarrc file with a new section:
#
# [github_contribution]
# username = mizoR
# max_contributions = 10

require 'erb'
require 'date'
require 'open-uri'

module BitBar
  class RcFile
    RcFileNotFound = Class.new(StandardError)

    def self.load(file = "#{ENV['HOME']}/.bitbarrc")
      raise RcFileNotFound if !File.exist?(file)

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

    def [](name)
      @sections[name.to_sym]
    end
  end

  module GitHubContribution
    class Contribution < Struct.new(:username, :contributed_on, :count)
      RE_CONTRIBUTION = %r|<rect class="day" .+ data-count="(\d+)" data-date="(\d\d\d\d-\d\d-\d\d)"/>|

      def self.find_all_by(username:)
        [].tap do |contributions|
          html = open(url_for(username: username)) { |f| f.read }

          html.scan(RE_CONTRIBUTION) do |count, date|
            contributions << Contribution.new(username, Date.parse(date), count.to_i)
          end
        end
      end

      def color
        count <= 0 ? 'brown' : 'green'
      end

      def icon
        case count
        when 0    then ':poop:'
        when 1..3 then ':seedling:'
        when 4..9 then ':herb:'
        else           ':deciduous_tree:'
        end
      end

      private

      def self.url_for(username:)
        "https://github.com/users/#{username}/contributions"
      end
    end

    class View
      TEMPLATE = <<-EOT.gsub(/^ */, '')
        <%= contribution.icon %><%= contribution.count %> | color=<%= contribution.color %>
        ---
        <% contributions.each do |c| -%>
        <%= helper.link_to(helper.contribution_text_for(c), helper.contribution_activity_for(c), color: c.color) %>
        <% end -%>
      EOT

      class Helper
        def link_to(text, href, options={})
          s = +"#{text} | href=#{href}"

          if !options.empty?
            s << ' '
            s << options.map { |option| option.join('=') }.join(' ')
          end

          s.freeze
        end

        def contribution_text_for(contribution)
          "#{contribution.icon} #{contribution.contributed_on.strftime('%Y-%m-%d (%a)')}   \t#{contribution.count}"
        end

        def contribution_activity_for(contribution)
          query    = "from=#{contribution.contributed_on}"
          fragment = "year-link-#{contribution.contributed_on.year}"

          "https://github.com/#{contribution.username}?#{query}##{fragment}"
        end
      end

      def initialize(contributions:)
        @contribution  = contributions.fetch(0)
        @contributions = contributions
        @helper        = Helper.new
      end

      def render
        b = binding

        instance_variables.each do |instance_variable|
          name  = instance_variable.to_s.sub(/\A@/, '')
          value = instance_variable_get(instance_variable)

          b.local_variable_set(name, value)
        end

        puts ERB.new(TEMPLATE, nil, '-').result(b)
      end
    end

    class App
      DEFAULT_CONFIG = { max_contributions: 10 }

      def initialize(config = {})
        config = cast_config(DEFAULT_CONFIG.merge(config))

        @username, @max_contributions = config.values_at(:username, :max_contributions)
      end

      def run
        contributions = Contribution.find_all_by(username: @username)
                                    .sort_by(&:contributed_on)
                                    .reverse
                                    .slice(0, @max_contributions)

        View.new(contributions: contributions).render
      end

      private

      def cast_config(username:, max_contributions:)
        username          = username.to_s
        max_contributions = max_contributions.to_i

        if username.empty?
          raise 'GitHub username is not given.'
        end

        if !max_contributions.positive?
          raise "Max contributions should be positive integer, but it was #{max_contributions}"
        end

        { username: username, max_contributions: max_contributions }
      end
    end
  end
end

if __FILE__ == $0
  begin
    config = BitBar::RcFile.load[:github_contribution].to_h

    BitBar::GitHubContribution::App.new(config).run
  rescue BitBar::RcFile::RcFileNotFound
    puts <<-EOM.gsub(/^ */, '')
      ⚠️
      ---
      To setup, create or edit your ~/.bitbarrc file with a new section:
      |
      ;# ~/.bitbarrc
      [github_contribution]
      username = <GITHUB USERNAME>
      max_contributions = 10
    EOM
  end
end