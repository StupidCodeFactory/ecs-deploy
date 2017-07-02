#!/usr/bin/env ruby

$:.unshift(File.join(File.expand_path(File.dirname(__FILE__)), 'lib'))

require 'bundler/setup'
Bundler.require(:default)
require 'aws-sdk'
require 'pp'
require 'yaml'
require 'optparse'
require 'args_parser'
require 'launch_configuration'
require 'auto_scaling_group'
require 'task_definition'
require 'service'

begin
  require 'byebug'
rescue LoadError
end

class ECSDeploy

  def initialize(options)
    self.cluster_name            = options.cluster_name
    self.task_definitions        = options.task_definitions.map { |td| TaskDefinition.new(ecs, td) }
    self.services                = options.services.map  { |s| Service.new(ecs, s) }
    self.autoscaling_group       = AutoScalingGroup.new(as, options.autoscaling_group)
    self.launch_configuration    = LaunchConfiguration.new(as, options.launch_configuration)
  end

  def create_cluster
    @cluster ||= ecs.create_cluster(cluster_name: cluster_name).cluster
  end

  def delete_cluster
    ecs.delete_cluster(cluster: cluster_name)
  end

  def create_launch_configuration
    return if launch_configuration.exists?
    launch_configuration.create
  end

  def create_auto_scaling_group
    unless autoscaling_group.exists?
      autoscaling_group.create
    end
  end

  def create_services
    @services = services.map do |service|
      if service.exist?
        definition = YAML.load_file(service).with_indifferent_access
        definition[:cluster] = cluster_name
        ecs.create_service(definition)
      else
        raise ArgumentError.new("service #{service} does not exists")
      end
    end
    @services
  end

  def delete
    autoscaling_group.delete
    launch_configuration.delete
    cluster.delete
  end

  def register_task_definitions
    @task_definitions = task_definitions.each(&:register)
  end

  private
  attr_accessor :cluster,
                :cluster_name,
                :services,
                :task_definitions,
                :autoscaling_group,
                :launch_configuration

  def ecs
    @ecs ||= Aws::ECS::Client.new(region: region)
  end

  def as
    @as ||= Aws::AutoScaling::Client.new(region: region)
  end

  def region
    'eu-west-1'
  end
end


if __FILE__ == $0
  options = ArgsParser.new.parse(ARGV)
  ecs = ECSDeploy.new(options)
  byebug
  ecs.cluster

  pp ecs.spawn_service
end
