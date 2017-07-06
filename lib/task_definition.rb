class TaskDefinition
  def initialize(client, config)
    self.client = client
    self.config = config.with_indifferent_access
  end

  def register
    @task_definition ||= register_task_definition
  end

  private
  attr_accessor :client, :config

  def register_task_definition
    client.register_task_definition(config)
  end

  def family
    config[:family]
  end
end
