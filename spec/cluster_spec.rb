require 'spec_helper'

RSpec.describe Cluster do
  let(:region) { 'eu-west-1' }
  let(:client) { Aws::ECS::Client.new(region: region) }
  let(:name) { Faker::Hipster.words(2, true, false).join('_') }

  subject { described_class.new(client, name) }

  describe '#create' do
    after { subject.delete }

    context 'when not created' do
      it 'is created' do
        expect(subject.create).to be_instance_of(described_class)
      end
    end

    context 'when created' do
      before do
        subject.create
      end

      it 'is not created' do
        expect(client).to_not receive(:create_cluster)
        subject.create
      end
    end
  end

  describe '#delete' do

    before { subject.create }

    it 'deletes the cluster' do
      expect {
        subject.delete
      }.to change { subject.status }.from('ACTIVE').to('INACTIVE')
    end
  end
end
