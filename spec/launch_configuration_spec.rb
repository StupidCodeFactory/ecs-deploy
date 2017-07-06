require 'spec_helper'
require 'launch_configuration'

RSpec.describe LaunchConfiguration do
  let(:region) { 'eu-west-1' }
  let(:client) { Aws::AutoScaling::Client.new(region: region) }
  let!(:config) { YAML.load_file('spec/fixtures/launch-configuration-test.yml').with_indifferent_access }
  let(:cluster_name) { 'cluster-name' }
  subject { described_class.new(client, config, Cluster.new(client, cluster_name)) }

  after do
    begin
      Aws::AutoScaling::Client.new(region: region).delete_launch_configuration(launch_configuration_name: config[:launch_configuration_name])
    rescue Aws::AutoScaling::Errors::ValidationError
    end
  end

  describe '#exists?' do
    context 'when not yet created' do
      it { is_expected.to_not be_exists }
    end
    context 'when created' do
      before do
        subject.create
      end

      it { is_expected.to be_exists }
    end
  end

  describe '#create' do
    context 'when not yet created' do
      it 'creates the launch configuration' do
        subject
        expect(Base64).to receive(:encode64).with("#!/bin/bash\necho ECS_CLUSTER=cluster-name >> /etc/ecs/ecs.config\n").
                            and_return("IyEvYmluL2Jhc2gKZWNobyBFQ1NfQ0xVU1RFUj1jbHVzdGVyLW5hbWUgPj4g\nL2V0Yy9lY3MvZWNzLmNvbmZpZwo=\n")
        config[:user_data] = "IyEvYmluL2Jhc2gKZWNobyBFQ1NfQ0xVU1RFUj1jbHVzdGVyLW5hbWUgPj4g\nL2V0Yy9lY3MvZWNzLmNvbmZpZwo=\n"
        expect(client).to receive(:create_launch_configuration).with(config)
        subject.create

      end
    end

    context 'when created' do
      it 'does not create the launch configuration' do
        subject.create
        expect(client).to_not receive(:create_launch_configuration)
        subject.create
      end
    end
  end

  describe '#delete' do
    context 'when existing' do
      before { subject.create }

      it 'is deleted' do
        expect(client).to receive(:delete_launch_configuration).with(launch_configuration_name: config[:launch_configuration_name])
        subject.delete
      end
    end

    context 'when not existing' do
      it 'does not try to be deleted' do
        expect(client).to_not receive(:delete_launch_configuration)
        subject.delete
      end
    end
  end

end
