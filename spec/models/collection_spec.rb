require 'rails_helper'

RSpec.describe Collection, type: :model do
  subject(:collection) { FactoryGirl.build(:collection_lw) }

  it_behaves_like 'a record with ordered fields' do
    let(:work) { collection }
  end

  it "can have an associated EAD" do
    expect(collection.ead.first).to start_with "EAD id"
  end
end
