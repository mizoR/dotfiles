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
    def self.load(file = "#{ENV['HOME']}/.bitbarrc")
      parse(open(file) { |f| f.read })
    end

    def self.parse(source)
      sections = {}

      section = nil

      source.each_line do |line|
        if line =~ /^ *;/
          # comment
          next
        end

        if line =~ /\[(.+)\]/
          section = sections[$1.to_sym] = {}
          next
        end

        if line =~ /(.+)=(.+)/
          section[$1.strip.to_sym] = $2.gsub(/^[ "]*|[ "]*$/, '')
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
        "https://github.com/users/%s/contributions" % username
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

      attr_reader :contributions

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
        @contributions = contributions
      end

      def render
        contribution = contributions.fetch(0)

        locals = {
          contribution:  contribution,
          contributions: contributions,
          helper:        Helper.new,
        }

        b = binding

        locals.each { |k, v| b.local_variable_set(k, v) }

        puts ERB.new(TEMPLATE, nil, '-').result(b)
      end
    end

    class ErrorView
      attr_reader :error

      def initialize(error:)
        @error = error
      end

      def render
        puts <<-EOT.gsub(/^ */, '')
          ✖︎ | color=red
          ---
          #{error.class}: #{error.message}
          ---
          #{error.backtrace.join("\n")}
        EOT
      end
    end

    class App
      def initialize(username:, max_contributions: 10)
        @username          = username
        @max_contributions = max_contributions.to_i
      end

      def run
        if @username.to_s.empty?
          raise 'GitHub user is not given.'
        end

        contributions = Contribution.find_all_by(username: @username)
                                    .sort_by(&:contributed_on)
                                    .reverse
                                    .slice(0, @max_contributions)

        View.new(contributions: contributions).render
      rescue => e
        ErrorView.new(error: e).render

        exit
      end
    end
  end
end

if __FILE__ == $0
  config = BitBar::RcFile.load[:github_contribution].to_h

  BitBar::GitHubContribution::App.new(config).run
end
