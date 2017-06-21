require 'bundler/setup'
require 'aws-sdk'

puts Aws.config

ecs = Aws::ECS::Client.new
puts ecs.operation_names.inspect
