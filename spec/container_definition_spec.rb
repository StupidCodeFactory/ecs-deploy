require 'spec_helper'

RSpec.describe Aws::ECS::Types::ContainerDefinition, type: :model do
  it { is_expected.to validate_presence_of :name }
  it { is_expected.to validate_presence_of :image }
  context 'when #port_mappings is has at least one element'  do
    before do
      subject.port_mappings = [{
          container_port: 1,
          host_port: 1,
          protocol: "tcp", # accepts tcp, udp
        }]
    end

    it { is_expected.to validate_presence_of :container_port }
  end
end
