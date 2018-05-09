module Schemas
  class TuftsImageSchema < ActiveTriples::Schema
    property :bits_per_sample, predicate: ::RDF::Vocab::EXIF.bitsPerSample
    property :resolution_unit, predicate: ::RDF::Vocab::EXIF.resolutionUnit
    property :samples_per_pixel, predicate: ::RDF::Vocab::EXIF.samplesPerPixel
    property :x_resolution, predicate: ::RDF::Vocab::EXIF.xResolution
    property :y_resolution, predicate: ::RDF::Vocab::EXIF.yResolution
  end
end
