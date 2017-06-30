require 'spec_helper'

RSpec.describe Aws::ECS::Types::TaskDefinition, type: :model do
  it { is_expected.to validate_presence_of :family }
  it { is_expected.to validate_length_of(:container_definitions).is_at_least(1) }
end
