class LaunchConfiguration
  def initialize(client, config)
    self.client = client
    self.config = config
  end

  def exists?
    !!(launch_configuration)
  end
  
  def create
    @launch_configuration ||= launch_configuration || client.create_launch_configuration(config)
  end

  def delete
    return unless launch_configuration
    client.delete_launch_configuration(launch_configuration_name: name)
  end
  
  private
  attr_accessor :config, :client

  def launch_configuration
    @launch_configuration ||= client.describe_launch_configurations(
      launch_configuration_names: [name]
    ).launch_configurations.first
  end

  def name
    config[:launch_configuration_name]
  end
end
