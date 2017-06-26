require 'bundler/setup'
require 'aws-sdk'
require 'pp'

class ECSDeploy

  def cluster
    pp ecs
    pp clusters
  end
  private
  
  def clusters
    @clusters ||= ecs.list_clusters
  end
  
  def ecs
    @ecs ||= Aws::ECS::Client.new(region: 'eu-west-1')
  end
end


