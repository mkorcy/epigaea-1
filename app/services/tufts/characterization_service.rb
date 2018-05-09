module Tufts
  class CharacterizationService
    FIELDS = {
      resolution_unit:            [:ifd0, 'ResolutionUnit'],
      bits_per_sample:            [:ifd0, 'BitsPerSample'],
      samples_per_pixel:          [:ifd0, 'SamplesPerPixel'],
      x_resolution:               [:ifd0, 'XResolution'],
      y_resolution:               [:ifd0, 'YResolution']
    }.freeze

    def self.run(object, source)
      new(object, source).characterize
    end

    def initialize(object, source)
      @object = object
      @source = source
    end

    def characterize
      extracted_md = map_fields_to_properties(exif_data)
      extracted_md.each { |property, value| append_property_value(property, value) }
    end

    private

      # Calls the Vendored Exif Tool with appriorate arguments and returns the hash
      def exif_data
        Exiftool.new(@source, '-a -u -g1').to_hash
      end

      def map_fields_to_properties(exif_data)
        {}.tap do |hash|
          FIELDS.keys.each do |field|
            hash[field.to_s] = exif_data.dig(*FIELDS[field])
          end
        end.compact
      end

      def append_property_value(property, value)
        @object.send("#{property}=", value)
      end
  end
end
