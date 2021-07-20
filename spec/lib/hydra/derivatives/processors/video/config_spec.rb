# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Hydra::Derivatives::Processors::Video::Config do
  subject(:video_config) { described_class.new }

  describe '#video_attributes' do
    it 'returns a string of video attributes for ffmpeg' do
      expect(video_config.video_attributes).to eq "-g 48 -keyint_min 48 -b:v 2500k -maxrate 2675k -bufsize 3750k"
    end
  end
end
