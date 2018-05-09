require 'rails_helper'

RSpec.describe Tufts::CharacterizationService do
  let(:file) { Hydra::PCDM::File.new }

  before do
    described_class.run(file, 'test1234')
  end

  it 'assigns expected values to characterized properties.' do
    expect(file.samples_per_pixel).to eq [1]
    expect(file.x_resolution).to eq [600]
    expect(file.y_resolution).to eq [600]
    expect(file.resolution_unit).to eq ['inches']
    expect(file.bits_per_sample).to eq [8]
  end
end
