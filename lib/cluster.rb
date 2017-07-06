class Cluster
  attr_reader :name
  def initialize(client, name)
    self.client = client
    self.name = name
  end

  def create
    STDOUT.puts "Creating cluster: #{name}"
    @cluster ||= cluster || client.create_cluster(cluster_name: name).cluster
  end

  def delete
    @cluster = client.delete_cluster(cluster: name).cluster
  end

  def status
    cluster['status']
  end

  private
  attr_accessor :client
  attr_writer :name

  def cluster
    client.describe_clusters(
      clusters: [name]
    ).clusters.first
  end
end
