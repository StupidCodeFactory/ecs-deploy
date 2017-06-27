require 'spec_helper'

RSpec.describe ArgsParser do
  let(:cluster) { 'ecs-deploy-cluster-test' }
  let(:service) { 'ecs-deploy-service-test' }
  let(:argv)    { ['-c', cluster, '-s', service] }

  it 'prints help' do
    expect { subject.parse(argv) }.to output(/Usage: ecs-deploy \[options\]/).to_stdout
  end

end
