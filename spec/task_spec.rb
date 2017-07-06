require 'spec_helper'
require 'task'

RSpec.describe Task do
  let(:region) { 'eu-west-1' }
  let(:client) { Aws::ECS::Client.new(region: region) }
  let(:config) { YAML.load_file('spec/fixtures/task-test.yml').with_indifferent_access }

  before(:all) do
    @config = ArgsParser.new.parse(
      [
        '-c', 'cluster_for_service_spec',
        '-a', 'spec/fixtures/autoscaling-group-test.yml',
        '-l', 'spec/fixtures/launch-configuration-test.yml',
        '-d', 'spec/fixtures/task-definition-test.yml',
        '-s', 'spec/fixtures/services-test.yml'
      ]
    )

    @config.cluster_name = Faker::Hipster.words(2, true, false).join('_')
    @deploy = ECSDeploy.new(@config)
    @deploy.create_cluster
    @deploy.launch_configuration.create
    @deploy.create_auto_scaling_group
    @deploy.register_task_definitions
    @deploy.launch_services
    @deploy.launch_configuration
  end

  after(:all) do
    @deploy.delete
  end

  subject { described_class.new(client, config, @deploy.cluster) }

  describe '#run' do
    it 'runs the task' do
      expect(subject.run).to eq('asdasda')
    end
  end
end
