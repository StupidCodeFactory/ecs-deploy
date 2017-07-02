require 'spec_helper'

RSpec.describe Service do
  let(:region) { 'eu-west-1' }
  let(:client) { Aws::ECS::Client.new(region: region) }
  let(:config) { YAML.load_file('spec/fixtures/services-test.yml').first.with_indifferent_access  }

  subject { described_class.new(client, config) }

  before(:all) do
    @config = ArgsParser.new.parse(
      [
        '-c', 'cluster_for_service_spec',
        '-a', 'spec/fixtures/autoscaling-group-test.yml',
        '-l', 'spec/fixtures/launch-configuration-test.yml',
        '-d', 'spec/fixtures/task-definition-test.yml'
      ]
    )

    @deploy = ECSDeploy.new(@config)
    VCR.use_cassette :setup_cluster_for_service_spec do
      @deploy.create_cluster
      @deploy.create_launch_configuration
      @deploy.create_auto_scaling_group
    end
  end

  after(:all, vcr: { cassette_name: :setup_cluster_for_service_spec, record: :new_episodes }) do
    @deploy.delete
  end

  describe '#create' do
    context 'when not created' do

      before do
        expect(subject).to receive(:exists?).and_return(false)
      end

      it 'is created' do
        expect(client).to receive(:create_service).with(config)
        subject.create
      end
    end

    context 'when not created' do
      before do
        subject.create
      end

      it 'is not created', vcr: { cassette_name: 'service_already_created', record: :once} do
        expect(client).to_not receive(:create_service)
        subject.create
      end
    end
  end
end
