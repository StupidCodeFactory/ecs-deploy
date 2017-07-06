#!/usr/bin/env ruby

$:.unshift(File.join(File.expand_path(File.dirname(__FILE__)), 'lib'))

require 'bundler/setup'
require 'aws-sdk'
require 'pp'
require 'yaml'
require 'optparse'
require 'args_parser'
require 'launch_configuration'
require 'cluster'
require 'auto_scaling_group'
require 'task_definition'
require 'service'

begin
  require 'byebug'
rescue LoadError
end

class ECSDeploy

  def initialize(options)
    self.cluster              = Cluster.new(ecs, options.cluster_name)
    self.task_definition      = TaskDefinition.new(ecs, options.task_definition)
    self.services             = options.services.map  { |s| Service.new(ecs, s, cluster) }
    self.autoscaling_group    = AutoScalingGroup.new(as, options.autoscaling_group)
    self.launch_configuration = LaunchConfiguration.new(as, options.launch_configuration, cluster)
  end

  def deploy
    create_cluster
    create_auto_scaling_group
    create_launch_configuration
    register_task_definitions
    launch_services
  end


  def delete
    services.map(&:delete)
    autoscaling_group.delete
    launch_configuration.delete
    cluster.delete
  end

  attr_reader :cluster, :autoscaling_group, :launch_configuration

  private

  attr_writer :cluster, :autoscaling_group, :launch_configuration
  attr_accessor :services,
                :task_definition

  def create_cluster
    cluster.create
  end

  def delete_cluster
    cluster.delete
  end

  def create_auto_scaling_group
    unless autoscaling_group.exists?
      autoscaling_group.create
    end
  end

  def register_task_definitions
    task_definition.register
  end

  def delete_launch_configuration
    if launch_configuration.exists?
      launch_configuration.delete
    end
  end

  def launch_services
    services.map(&:create)
  end

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
  ecs.deploy
end
