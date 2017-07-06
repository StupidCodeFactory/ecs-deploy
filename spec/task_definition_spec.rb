require 'spec_helper'
require 'task_definition'
RSpec.describe TaskDefinition do

  let(:region) { 'eu-west-1' }
  let(:client) { Aws::ECS::Client.new(region: region) }
  let(:config) { YAML.load_file('spec/fixtures/task-definition-test.yml').first.with_indifferent_access }

  subject { described_class.new(client, config) }

  describe '#register' do
    describe "when not registered" do
      it 'is registered' do
        # expect(client).to receive(:register_task_definition).with(config)
        subject.register
      end
    end

  end
end
