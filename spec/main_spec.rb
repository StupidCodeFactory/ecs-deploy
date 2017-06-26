
require 'spec_helper'
require 'byebug'

RSpec.describe ECSDeploy, vcr: { cassette_name: 'cluster_steps', record: :new_episodes}  do

  let(:ecs_client) { Aws::ECS::Client.new(region: 'eu-west-1') }
  
  it 'initialise an AWS client' do
    # expect(Aws::ECS::Client).to receive(:new).with(region: 'eu-west-1').and_return(ecs_client)
    subject.cluster
  end
  
  it 'creates a cluster' do
    # expect(subject.cluster).to eq()
  end
  
end
