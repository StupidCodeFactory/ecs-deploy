#!/usr/bin/env ruby

$:.unshift(File.join(File.expand_path(File.dirname(__FILE__)), 'lib'))

require 'bundler/setup'
require 'aws-sdk'
require 'pp'
require 'yaml'
require 'optparse'
require 'args_parser'
require 'active_support/core_ext/hash/indifferent_access'
# require 'active_support/hash_with_indifferent_access'
require 'launch_configuration'

begin
  require 'byebug'
rescue LoadError
end

class ECSDeploy

  def initialize(options)
    self.cluster_name            = options.cluster_name
    self.task_definitions        = options.task_definitions.map { |td| Pathname.new(td)}
    self.services                = options.services.map { |s| Pathname.new(s) }
    self.container_instance_file = Pathname.new(options.container_instance_file)
    self.autoscaling_group_file  = Pathname.new(options.autoscaling_group_file)
    self.launch_configuration    = LaunchConfiguration.new(YAML.load_file(options.launch_configuration_file).with_indifferent_access)
  end

  def create_cluster
    @cluster ||= ecs.create_cluster(cluster_name: cluster_name).cluster
  end

  def delete_cluster
    ecs.delete_cluster(cluster: cluster_name)
  end

  def create_services
    unless container_instances.any?
      STDOUT.puts "Registering new instance to cluster #{cluster_name}"
      register_container_instance
    end

    @services = services.map do |service|
      if service.exist?
        definition = YAML.load_file(service).with_indifferent_access
        ecs.create_service(definition)
      else
        raise ArgumentError.new("service #{service} does not exists")
      end
    end
    @services
  end
  # def spawn_service
  #   services = ecs.describe_services(cluster: cluster_name, services: [service_name]).services
  #   if services.empty? && task_definition
  #     STDOUT.puts("Service #{service_name} unknown, creating #{service_name}")
  #     ecs.create_service(
  #       desired_count: 1,
  #       service_name: service_name,
  #       task_definition: task_definition_name
  #     )
  #   end
  # end

  def register_task_definitions
    @task_definitions = task_definitions.map do |task_definition|
      if task_definition.exist?
        definition = YAML.load_file(task_definition).with_indifferent_access
        ecs.register_task_definition(definition)
      else
        raise ArgumentError.new("task definitions #{task_definition} does not exists")
      end
    end
  end

  private
  attr_accessor :cluster_name,
                :services,
                :task_definitions,
                :container_instance_file,
                :autoscaling_group_file,
                :launch_configuration

  def register_container_instance
    
    if launch_configuration.exists?
      
      # if autoscaling_group
      #   as.delete_auto_scaling_group(
      #     auto_scaling_group_name: auto_scaling_group_definition[:auto_scaling_group_name],
      #     force_delete: true
      #   )
      # end
      
      # as.wait_until :group_not_exists do |w|

      #   w.before_attempt do |attempts|
      #     STDOUT.puts "#{attempts}: Waiting for autoscaling group..."
      #   end
      # end


      # as.delete_launch_configuration(launch_configuration_name: launch_configuration[:launch_configuration_name])
    else
      launch_configuration.create
    end
    
    

    if autoscaling_group
      as.update_auto_scaling_group(
        auto_scaling_group_name: auto_scaling_group_definition[:auto_scaling_group_name],
        launch_configuration_name: launch_configuration[:launch_configuration_name]
      )
    else
      as.create_auto_scaling_group(auto_scaling_group_definition)
    end

    as.wait_until :group_in_service do |w|

      w.before_attempt do |attempts|
        STDOUT.puts "#{attempts}: Waiting for autoscaling group..."
      end
    end

    byebug
    definition = YAML.load_file(container_instance_file).with_indifferent_access
    definition[:cluster] = cluster_name
    ecs.register_container_instance definition
  end
  
  def auto_scaling_group_definition
    @auto_scaling_group_definition ||= YAML.load_file(autoscaling_group_file).with_indifferent_access
  end

  
  def task_definition
    @task_definition ||= ecs.describe_task_definition(task_definition: task_definition_name)
  end

  def services
    @services ||= client.list_services(cluster: cluster_name)
  end

  def cluster
    @cluster ||= clusters.detect { |cluster| cluster }
  end

  def clusters
    ecs.list_clusters.cluster_arns
  end

  def container_instances
    @container_instances = ecs.list_container_instances(cluster: cluster_name).container_instance_arns
  end

  def ecs
    @ecs ||= Aws::ECS::Client.new(region: region)
  end

  def as
    @as ||= Aws::AutoScaling::Client.new(region: region)
  end

  def instance
    @instance ||= ec2.create_instances(instance_type: 't1.micro')
  end

  def ec2
    @ec2 ||= Aws::EC2::Resource.new(client:  Aws::EC2::Client.new(region: region))
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
