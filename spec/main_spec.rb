require 'spec_helper'
require 'byebug'

RSpec.describe ECSDeploy, vcr: { cassette_name: 'cluster_steps', record: :new_episodes}  do

  let(:ecs_client) { Aws::ECS::Client.new(region: 'eu-west-1') }
  let(:cluster_name) { 'ecs-deploy-wercker-step' }
  let(:ec2) { Aws::EC2::Client.new(region: 'eu-west-1') }
  let(:resource) { Aws::EC2::Resource.new(client: ec2) }
  
  subject { described_class.new(cluster_name) }
  after do
    subject.delete_cluster
  end
  
  describe '#cluster' do
    it 'creates a cluster' do
      expect(subject.cluster.cluster_name).to eq(cluster_name)
      expect(subject.cluster.cluster_arn).to eq('arn:aws:ecs:eu-west-1:466565482925:cluster/ecs-deploy-wercker-step')
    end
  end

end

