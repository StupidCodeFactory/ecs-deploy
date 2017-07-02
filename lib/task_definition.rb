class TaskDefinition
  def initialize(client, config)
    self.client = client
    self.config = config
  end

  def register
    @task_definition ||= task_definition || register_task_definition
  end

  private
  attr_accessor :client, :config

  def task_definition
    return if task_definition_arns.empty?
    client.describe_task_definition(task_definition: last_task_definition_arn)
  end

  def last_task_definition_arn
    task_definition_arns.last
  end

  def task_definition_arns
    client.list_task_definitions(family_prefix: family).task_definition_arns
  end

  def register_task_definition
    client.register_task_definition(config)
  end

  def family
    config[:family]
  end
end
