#!/usr/bin/env ruby

ENV['PATH'] = "/usr/local/bin:#{ENV['PATH']}"

require 'date'
require 'json'

ICON       = DATA.gets
START_TIME = (Date.today - 1).to_datetime
END_TIME   = Date.today.to_datetime - Rational(1, 86400)
PERIOD     = 86400

def list_metrics
  dimensions = [ { Name: 'Currency', Value: 'USD' } ]

  command = %Q|aws cloudwatch list-metrics \
    --namespace AWS/Billing \
    --metric-name EstimatedCharges \
    --region us-east-1 \
    --dimensions '#{dimensions.to_json}'|

  source = open("| #{command}") { |io| io.read }

  JSON.parse(source).fetch('Metrics')
end

def get_billing(namespace:, metric_name:, dimensions:)
  command = %Q|aws cloudwatch get-metric-statistics \
           --namespace '#{namespace}' \
           --metric-name '#{metric_name}' \
           --start-time '#{START_TIME}' \
           --end-time '#{END_TIME}' \
           --period '#{PERIOD}' \
           --statistics 'Sum' \
           --region 'us-east-1' \
           --dimensions '#{dimensions}'|

  source = open("| #{command}") { |io| io.read }

  datapoints = JSON.parse(source).fetch('Datapoints')

  datapoints.fetch(0).fetch('Sum')
end

metrics = list_metrics

billings = metrics.each_with_object({}) do |metric, hash|
  params = {
    namespace:   metric['Namespace'],
    metric_name: metric['MetricName'],
    dimensions:  metric['Dimensions'].to_json,
  }

  service_name = metric['Dimensions'].find { |d| d['Name'] == 'ServiceName' }&.fetch('Value')
  service_name ||= 'Total'

  hash[service_name]  = get_billing(params)
end

puts "$#{billings['Total']} | image=#{ICON}"
puts '---'

billings.each do |name, billing|
  puts "#{name}: $#{billing} | color=grey"
end

puts '---'
puts 'Open CloudWatch | href=https://console.aws.amazon.com/cloudwatch/home'

__END__
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
