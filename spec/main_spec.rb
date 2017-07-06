require 'spec_helper'
require 'byebug'

RSpec.describe ECSDeploy, vcr: { cassette_name: 'cluster_steps', record: :new_episodes}  do

  let(:ecs_client)   { Aws::ECS::Client.new(region: 'eu-west-1') }
  let(:cluster_name) { Faker::Hipster.words(2,true, false).join('_') }
  let(:ec2)          { Aws::EC2::Client.new(region: 'eu-west-1') }
  let(:resource)     { Aws::EC2::Resource.new(client: ec2) }
  let(:config)   do
    ArgsParser.new.parse(
      [
        '-c', cluster_name,
        '-a', 'spec/fixtures/autoscaling-group-test.yml',
        '-d', 'spec/fixtures/task-definition-test.yml',
        '-l', 'spec/fixtures/launch-configuration-test.yml',
        '-s', 'spec/fixtures/services-test.yml'
      ]
    )
  end

  subject { described_class.new(config) }

  before do
    config.autoscaling_group['auto_scaling_group_name'] = [cluster_name, 'auto_scaling_group'].join('-')
    config.launch_configuration['launch_configuration_name'] = [cluster_name, 'launch_configuration'].join('-')
  end

  after do
    subject.delete_cluster
  end

  describe '#cluster' do
    it 'creates the cluster' do
      expect(subject.create_cluster).to be_instance_of(Aws::ECS::Types::Cluster)
    end
  end

  describe '#deploy' do
    it 'register the task definition' do
      subject.create_cluster
      subject.launch_configuration.create
      subject.create_auto_scaling_group
      subject.register_task_definitions
      subject.launch_services
    end
  end
end
