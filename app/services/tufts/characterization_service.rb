require 'shellwords'
require 'mimemagic'
require 'fastimage'

module Tufts
  class CharacterizationService
    FIELDS = {
      resolution_unit:            [:ifd0, 'ResolutionUnit'],
      bits_per_sample:            [:ifd0, 'BitsPerSample'],
      samples_per_pixel:          [:ifd0, 'SamplesPerPixel'],
      x_resolution:               [:ifd0, 'XResolution'],
      y_resolution:               [:ifd0, 'YResolution'],
      height:                     [:ifd0, 'ImageHeight'],
      width:                      [:ifd0, 'ImageWidth']
    }.freeze

    def self.run(object, source)
      new(object, source).characterize
    end

    def initialize(object, source)
      @object = object
      @source = source
    end

    # rubocop:disable Metrics/CyclomaticComplexity, Metrics/MethodLength, Metrics/PerceivedComplexity
    def characterize
      if !@object.mime_type.nil? && @object.mime_type == "TBD"
        mimetype = `file --brief --mime-type - < #{Shellwords.shellescape(@source)}`.strip
        if mimetype == "application/octet-stream"
          # if we don't characterize this as a video it won't get derivatives
          type_obj = MimeMagic.by_path(@source)
          mimetype = type_obj.type unless type_obj.nil?
          # mimetype = "video/mp4"
        end
        append_property_value("mime_type", mimetype)
      end
      extracted_md = map_fields_to_properties(exif_data)
      size_array = FastImage.size(@source)
      unless size_array.nil?
        append_property_value("width", size_array[0]) if size_array.length >= 2
        append_property_value("height", size_array[1]) if size_array.length >= 2
      end
      extracted_md.each { |property, value| append_property_value(property, value) }
    end

    private

      # Calls the Vendored Exif Tool with appriorate arguments and returns the hash
      def exif_data
        Exiftool.new(@source, '-a -u -g1').to_hash
      end

      def map_fields_to_properties(exif_data)
        {}.tap do |hash|
          FIELDS.each_key do |field|
            hash[field.to_s] = exif_data.dig(*FIELDS[field])
          end
        end.compact
      end

      def append_property_value(property, value)
        @object.send("#{property}=", value)
      end
  end
end
