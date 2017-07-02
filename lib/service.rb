class Service
  def initialize(client, config)
    self.client = client
    self.config = config
  end

  def create
    return if exists?
    pp client.create_service(config)
  end

  private
  attr_accessor :client, :config

  def exists?
    pp services
  end

  def services
    client.list_services(cluster_name: cluster_name)
  end

  def cluster_name
    config[:cluster_name]
  end
end
