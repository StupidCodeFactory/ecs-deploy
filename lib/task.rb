class Task
  def initialize(client, config, cluster)
    self.client  = client
    self.config  = config
    self.cluster = cluster
  end

  def run
    response = client.run_task(config.merge(cluster: cluster_name))
    task_arns = response.tasks.map(&:task_arn)
    client.wait_until :tasks_stopped, cluster: cluster_name,  tasks: task_arns do |w|
      w.before_attempt do |attempts|
        STDOUT.puts "#{attempts}: Waiting for task #{name} in cluster #{cluster_name} to finish execution ..."
      end
    end

  end

  private
  attr_accessor :client, :config, :cluster

  def name
    config[:task_definition]
  end

  def cluster_name
    cluster.name
  end
end
