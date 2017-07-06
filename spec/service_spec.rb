require 'spec_helper'

RSpec.describe Service do
  let(:region) { 'eu-west-1' }
  let(:client) { Aws::ECS::Client.new(region: region) }
  let(:config) { YAML.load_file('spec/fixtures/services-test.yml').first.with_indifferent_access  }
  let(:cluster) { @deploy.cluster }
  subject { described_class.new(client, config, cluster) }

  before(:all) do
    @config = ArgsParser.new.parse(
      [
        '-c', 'cluster_for_service_spec',
        '-a', 'spec/fixtures/autoscaling-group-test.yml',
        '-l', 'spec/fixtures/launch-configuration-test.yml',
        '-d', 'spec/fixtures/task-definition-test.yml'
      ]
    )

    @config.cluster_name = Faker::Hipster.words(2, true, false).join('_')
    @deploy = ECSDeploy.new(@config)
    @deploy.create_cluster
    @deploy.launch_configuration.create
    @deploy.create_auto_scaling_group
    @deploy.register_task_definitions
  end

  after(:all) do
    @deploy.delete
  end

  describe 'with an existant service' do
    before do
      config[:service_name] = Faker::Hipster.words(2, true, false).join('_')
      subject.create
    end

    describe 'craete or update' do
      after { subject.delete }

      it 'is not created' do
        subject.create
      end

      describe '#update' do

        it 'update the current service' do
          expect(subject.update(desired_count: 0).desired_count).to eq(0)
        end
      end
    end
    describe '#delete' do
      it 'is deleted' do
        subject.create
        expect(subject.delete.status).to eq('INACTIVE')
      end
    end
  end

  describe '#create' do

    context 'when not created' do
      after { subject.delete }
      it 'is created' do
        subject.create
      end
    end
  end
end
