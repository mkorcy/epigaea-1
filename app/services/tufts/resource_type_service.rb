module Tufts
  module ResourceTypeService
    mattr_accessor :authority
    self.authority = Qa::Authorities::Local.subauthority_for('resource_types')

    def self.select_options
      authority.all.map do |element|
        [element[:label], element[:id]]
      end
    end

    def self.label(id)
      authority.find(id).fetch('term')
    end
  end
end
