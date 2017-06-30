require 'spec_helper'
require 'launch_configuration'

RSpec.describe LaunchConfiguration do
  let(:region) { 'eu-west-1' }
  let(:client) { Aws::AutoScaling::Client.new(region: region) }
  let(:config) { YAML.load_file('spec/fixtures/launch-configuration-test.yml').with_indifferent_access }

  subject { described_class.new(client, config) }

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
