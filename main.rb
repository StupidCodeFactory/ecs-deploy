#!/usr/bin/env ruby

$:.unshift(File.join(File.expand_path(File.dirname(__FILE__)), 'lib'))

require 'bundler/setup'
require 'aws-sdk'
require 'pp'
require 'optparse'
require 'args_parser'

class ECSDeploy

  def initialize(cluster_name)
    self.cluster_name = cluster_name
  end

  def cluster
    @cluster ||= ecs.create_cluster(cluster_name: cluster_name).cluster
  end

  def delete_cluster
    ecs.delete_cluster(cluster: cluster_name)
  end
  
  def register_task_definition(task_definition)
    pp ecs.list_task_definition_families
    ecs.register_task_definition(task_definition)
  end
  
  private
  attr_accessor :cluster_name
  
  def clusters
    @clusters ||= ecs.list_clusters
  end
  
  def ecs
    @ecs ||= Aws::ECS::Client.new(region: 'eu-west-1')
  end

  def instance
    @instance ||= ec2.create_instances(instance_type: 't1.micro')
  end

  def ec2
    @ec2 ||= Aws::EC2::Resource.new(client:  Aws::EC2::Client.new(region: 'eu-west-1'))
  end
end


if __FILE__ == $0
  s = ArgsParser.new.parse(ARGV)
  ecs = ECSDeploy.new(s.cluster_name)
  ecs.cluster
end
