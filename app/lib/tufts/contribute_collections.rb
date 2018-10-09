module Tufts
  # Create and maintain the Collection objects required by the Contribute controller
  class ContributeCollections
    attr_reader :seed_data

    def initialize
      @seed_data = make_seed_data_hash
    end

    def make_seed_data_hash
      seed_hash = {}
      SEED_DATA.each do |c|
        ead = c[:ead]
        seed_hash[ead] = c
      end
      seed_hash
    end

    def self.create
      Tufts::ContributeCollections.new.create
    end

    def create
      @seed_data.each_key do |collection_id|
        find_or_create_collection(collection_id)
      end
    end

    # Given a collection id, find or create the collection.
    # If the collection has been deleted, eradicate it so the id can be
    # re-used, and re-create the collection object.
    # @param [String] ead_id
    # @return [Collection]
    def find_or_create_collection(ead_id)
      col = Collection.where(ead: ead_id)
      create_collection(ead_id) if col.empty?
    end

    # @param [String] ead_id
    # @return [Collection]
    def create_collection(ead_id)
      collection = Collection.new
      collection_hash = @seed_data[ead_id]
      collection.title = Array(collection_hash[:title])
      collection.ead = Array(collection_hash[:ead])
      collection.visibility = Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC
      collection.save
      collection
    end

    # Convenience method for use by the contribute controller
    # @param [Class] work_type
    # @return [Collection]
    # @example
    #  Tufts::ContributeCollections.collection_for_work_type(FacultyScholarship)
    def self.collection_for_work_type(work_type)
      Tufts::ContributeCollections.new.collection_for_work_type(work_type)
    end

    # For a given work type, determine which Collection contributions should go into.
    # If that collection object doesn't exist for some reason, create it.
    # @param [Class] work_type
    # @return [Collection]
    def collection_for_work_type(work_type)
      ead_id = @seed_data.select { |_key, hash| hash[:work_types].include? work_type }.keys.first

      cols = Collection.where(ead: ead_id)
      if cols.empty?
        create_collection(ead_id)
      else
        cols.first
      end
    end

    SEED_DATA = [
      {
        title: "Tufts Published Scholarship, 1987-2014",
        ead: "tufts:UA069.001.DO.PB",
        work_types: [GenericDeposit, GenericTischDeposit, GisPoster, UndergradSummerScholar, FacultyScholarship]
      },
      {
        title: "Fletcher School Records, 1923 -- 2016",
        ead: "tufts:UA069.001.DO.UA015",
        work_types: [CapstoneProject]
      },
      {
        title: "Cummings School of Veterinary Medicine records, 1969-2012",
        ead: "tufts:UA069.001.DO.UA041",
        work_types: [CummingsThesis]
      },
      {
        title: "Undergraduate honors theses, 1929-2015",
        ead: "tufts:UA069.001.DO.UA005",
        work_types: [HonorsThesis]
      },
      {
        title: "Public Health and Professional Degree Programs Records, 1990 -- 2011",
        ead: "tufts:UA069.001.DO.UA187",
        work_types: [PublicHealth]
      },
      {
        title: "Department of Education records, 2007-02-01-2014",
        ead: "tufts:UA069.001.DO.UA071",
        work_types: [QualifyingPaper]
      }
    ].freeze
  end
end
