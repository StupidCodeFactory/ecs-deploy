require 'spec_helper'
require 'byebug'

RSpec.describe ECSDeploy, vcr: { cassette_name: 'cluster_steps', record: :new_episodes}  do

  let(:ecs_client) { Aws::ECS::Client.new(region: 'eu-west-1') }
  let(:cluster_name) { 'ecs-deploy-wercker-step' }
  let(:ec2) { Aws::EC2::Client.new(region: 'eu-west-1') }
  let(:resource) { Aws::EC2::Resource.new(client: ec2) }
  let(:options) do
    double('CliOptions',
           cluster_name: cluster_name,
           task_definitions: ['spec/fixtures/test-definition-test.yml'],
           services: ['spec/fixtures/services-test.yml'],
           container_instance_file: 'spec/fixtures/container-instance-test.yml',
           autoscaling_group_file: 'spec/fixtures/autoscaling-group-test.yml',
           launch_configuration_file: 'spec/fixtures/launch-configuration-test.yml'
          ) 
  end

  subject { described_class.new(options) }

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

      subject.register_task_definitions
      subject.create_services
    end
  end
end
