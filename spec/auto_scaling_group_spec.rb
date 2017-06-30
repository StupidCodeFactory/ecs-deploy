require 'spec_helper'
require 'auto_scaling_group'

RSpec.describe AutoScalingGroup, :vcr do
  let(:region) { 'eu-west-1' }
  let(:client) { Aws::AutoScaling::Client.new(region: region) }
  let(:launch_configuration_config) { YAML.load_file('spec/fixtures/launch-configuration-test.yml').with_indifferent_access }
  let(:config) { YAML.load_file('spec/fixtures/autoscaling-group-test.yml').with_indifferent_access }
  let(:launch_configuration) { LaunchConfiguration.new(client, launch_configuration_config)  }

  subject { described_class.new(client, config) }
  before { launch_configuration.create }
  after do
    begin
      clean_up_client = Aws::AutoScaling::Client.new(region: region)
      clean_up_client.delete_auto_scaling_group(
        auto_scaling_group_name: config[:auto_scaling_group_name],
        force_delete: true
      )
      clean_up_client.wait_until :group_not_exists do |w|
        w.before_attempt do |attempts|
          STDOUT.puts "RSpec: #{attempts}: Waiting for autoscaling group clean up..."
        end
      end

    rescue Aws::AutoScaling::Errors::ValidationError
    end
    launch_configuration.delete
  end

  describe '#exists?' do
    context 'when not yet created' do
      it { is_expected.to_not be_exists }
    end

    context 'when created' do
      it { is_expected.to be_exists }
    end
  end
  
  describe '#create' do
    context 'when not yet created' do
      it 'is created' do
        expect(client).to receive(:create_auto_scaling_group).with(config)
        subject.create
      end
    end

    context 'when created' do
      it 'is not created' do
        subject.create
        expect(client).to_not receive(:create_auto_scaling_group)
        subject.create
      end
    end
  end

  describe '#delete' do
    context 'when existing' do
      before { subject.create }

      it 'is deleted' do
        expect(client).
          to receive(:delete_auto_scaling_group).
               with(
                 auto_scaling_group_name: config[:auto_scaling_group_name], force_delete: true)
        subject.delete
      end
    end

    context 'when not existing' do
      it 'does not try to be deleted' do
        expect(client).to_not receive(:delete_auto_scaling_group)
        subject.delete
      end
    end
  end

  describe "#instances" do
    context 'when existing' do
      before do
        subject.create
      end

      it 'returns instance arns' do
        expect(subject.instances).to_not be_empty
      end
    end

    context 'when not existing' do
      it { expect(subject.instances).to be_empty }
    end
  end
end
