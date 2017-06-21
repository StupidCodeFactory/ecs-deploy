require 'bundler/setup'
require 'aws-sdk'

puts Aws.config

ecs = Aws::ECS::Client.new(region: 'eu-west-1')
puts ecs.operation_names.inspect
