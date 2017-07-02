require 'launch_configuration'

class AutoScalingGroup
  def initialize(client, config)
    self.client = client
    self.config = config.with_indifferent_access
  end

  def instances
    return [] unless exists?
     @instances ||= client.describe_auto_scaling_instances[:auto_scaling_instances]
  end

  def exists?
    !!autoscaling_group
  end

  def create
    @auto_scaling_group ||= autoscaling_group || create_auto_scaling_group
  end

  def delete
    return unless autoscaling_group
    client.delete_auto_scaling_group(auto_scaling_group_name: name, force_delete: true)
    client.wait_until :group_not_exists do |w|
      w.before_attempt do |attempts|
        STDOUT.puts "#{attempts}: Waiting for autoscaling group to be deleted..."
      end
    end
  end


  private
  attr_accessor :config, :client

  def autoscaling_group
    @autoscaling_group ||= client.describe_auto_scaling_groups(
      auto_scaling_group_names: [name]
    ).auto_scaling_groups.first
  end

  def name
    config[:auto_scaling_group_name]
  end

  def create_auto_scaling_group
    begin
      client.create_auto_scaling_group(config)
      client.wait_until :group_in_service do |w|

        w.before_attempt do |attempts|
          STDOUT.puts "#{attempts}: Waiting for autoscaling group to be in service..."
        end
      end
    end
  end

end
