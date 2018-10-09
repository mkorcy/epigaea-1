require 'rails_helper'

RSpec.describe Tufts::ContributeCollections, :clean do
  let(:cc) { described_class.new }

  it "has a hash of all the collections to be made, with their ids and titles" do
    expect(cc.seed_data).to be_instance_of(Hash)
  end

  context "creating all the collections" do
    before do
      described_class.create
    end
    it "creates a collection object for each item in the seed array" do
      expect(Collection.count).to eq(6)
    end
    it "populates title and legacy identifier" do
      c = Collection.where(ead: "tufts:UA069.001.DO.PB")
      expect(c.first.title.first).to eq("Tufts Published Scholarship, 1987-2014")
      expect(c.first.ead.first).to eq("tufts:UA069.001.DO.PB")
    end
  end

  context "putting contributed works into collections" do
    before do
      described_class.create
    end
    it "finds the right collection for a given work type" do
      faculty_scholarship_collection = cc.collection_for_work_type(FacultyScholarship)
      expect(faculty_scholarship_collection).to be_instance_of(Collection)
      expect(faculty_scholarship_collection.ead).to eq(['tufts:UA069.001.DO.PB'])
    end
    it "recovers if one of the expected collections has been deleted" do
      Collection.where(ead: 'tufts:UA069.001.DO.PB').first.delete
      faculty_scholarship_collection = cc.collection_for_work_type(FacultyScholarship)
      expect(faculty_scholarship_collection).to be_instance_of(Collection)
      expect(faculty_scholarship_collection.ead).to eq(['tufts:UA069.001.DO.PB'])
    end
  end
end
