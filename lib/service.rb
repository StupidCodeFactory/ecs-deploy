class Service
  def initialize(client, config, cluster)
    self.client  = client
    self.config  = config.with_indifferent_access
    self.cluster = cluster
  end

  def delete
    update(desired_count: 0)
    client.delete_service(
      service: name,
      cluster: cluster_name
    )
    response = client.wait_until :services_inactive, cluster: cluster_name,  services: [name] do |w|
      w.before_attempt do |attempts|
        STDOUT.puts "#{attempts}: Waiting for service #{name} in cluster #{cluster_name} to be inactive..."
      end
    end
    response.services.first
  end

  def update(new_config = nil)
    new_config ||= config.dup
    new_config[:service] = config[:service_name]
    new_config[:cluster] = cluster_name
    client.update_service(new_config).service
  end

  def create
    return if exists?
    client.create_service(config.merge(cluster: cluster_name))
    client.wait_until :services_stable, cluster: cluster_name,  services: [name] do |w|
      w.before_attempt do |attempts|
        STDOUT.puts "#{attempts}: Waiting for service #{name} in cluster #{cluster_name} to be active ..."
      end
    end
  end

  private
  attr_accessor :client, :config, :cluster

  def exists?
    services.any?
  end

  def services
    client.describe_services(cluster: cluster_name, services: [name]).services
  end

  def cluster_name
    cluster.name
  end

  def name
    config[:service_name]
  end
end
