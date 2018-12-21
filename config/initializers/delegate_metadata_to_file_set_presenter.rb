Hyrax::FileSetPresenter.class_eval do
  delegate :bits_per_sample, :resolution_unit, :samples_per_pixel, :x_resolution, :y_resolution, :file_date_created,
           to: :solr_document
end
