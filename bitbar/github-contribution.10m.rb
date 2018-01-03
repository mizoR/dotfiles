#!/usr/bin/env ruby

# <bitbar.title>Github Contribution</bitbar.title>
# <bitbar.version>v0.0.1</bitbar.version>
# <bitbar.author>mizoR</bitbar.author>
# <bitbar.author.github>mizoR</bitbar.author.github>
# <bitbar.image></bitbar.image>
# <bitbar.dependencies>ruby</bitbar.dependencies>

require 'erb'
require 'date'
require 'open-uri'

module BitBar
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

      private

      def self.url_for(username:)
        "https://github.com/users/%s/contributions" % username
      end
    end

    class View
      TEMPLATE = <<-EOT.gsub(/^ */, '')
        <%= icon %> <%= contribution_count %> contributions | color=<%= color %>
        ---
        <% contributions.each do |c| -%>
        <%= helper.link_to(helper.contribution_text_for(c), helper.contribution_activity_for(c)) %>
        <% end -%>
      EOT

      attr_reader :contributions

      class Helper
        def link_to(text, href)
          "#{text} | href=#{href}"
        end

        def contribution_text_for(contribution)
          "#{contribution.contributed_on.strftime('%Y-%m-%d (%a)')}  \t#{contribution.count}"
        end

        def contribution_activity_for(contribution)
          uri = URI::HTTPS.build(
            host:     'github.com',
            path:     "/#{contribution.username}",
            query:    { from: contribution.contributed_on }.map { |kv| kv.join('=') }.join('&'),
            fragment: "year-link-#{contribution.contributed_on.year}"
          )

          uri.to_s
        end
      end

      def initialize(contributions:)
        @contributions = contributions
      end

      def render
        contribution = contributions.fetch(0)

        locals = {
          contributions:      contributions,
          contribution_count: contribution.count,
          icon:               contribution.count > 0 ? ':seedling:' : ':fallen_leaf:',
          color:              contribution.count > 0 ? 'green' : 'brown',
          helper:             Helper.new
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
          Error: #{error.message}
        EOT
      end
    end

    class App
      def run
        if username.to_s.empty?
          raise 'GitHub user is not given.'
        end

        contributions = Contribution.find_all_by(username: username)
                                    .sort_by(&:contributed_on)
                                    .reverse
                                    .slice(0, 7)

        View.new(contributions: contributions).render
      rescue => e
        ErrorView.new(error: e).render

        exit
      end

      private

      def username
        @username ||= ENV['BITBAR_GITHUB_CONTRIBUTION_USERNAME'] || `git config --get github.user`.chomp
      end
    end
  end
end

if __FILE__ == $0
  BitBar::GitHubContribution::App.new.run
end
