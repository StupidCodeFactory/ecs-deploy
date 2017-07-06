require 'base64'
require 'erb'

class LaunchConfiguration
  def initialize(client, config, cluster)
    self.client  = client
    self.config  = config.with_indifferent_access
    self.cluster = cluster
    config[:launch_configuration_name] ||= "#{cluster_name}-launch-configuration"
  end

  def exists?
    !!(launch_configuration)
  end

  def create
    ensure_user_data_base64_encoded
    @launch_configuration ||= launch_configuration || create_launch_configuration
  end

  def delete
    return unless launch_configuration
    client.delete_launch_configuration(launch_configuration_name: name)
  end

  private
  attr_accessor :config, :client, :cluster

  def create_launch_configuration
    STDOUT.puts 'Creating %s launch configuration' % name
    config[]
    client.create_launch_configuration(config)
  end


  def launch_configuration

    @launch_configuration ||= begin
                                client.describe_launch_configurations(
                                  launch_configuration_names: [name]
                                ).launch_configurations.first
                              end
  end

  def ensure_user_data_base64_encoded
    if config.key? :user_data
      config[:user_data] = Base64.encode64(ERB.new(config[:user_data]).result(binding))
    end
  end

  def cluster_name
    cluster.name
  end

  def name
    config[:launch_configuration_name]
  end
end
