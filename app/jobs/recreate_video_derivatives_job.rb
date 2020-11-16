class RecreateVideoDerivativesJob < CreateDerivativesJob
  queue_as(:batch_recreate_video_derivatives)

  # @param [FileSet] file_set
  # @param [String] file_id identifier for a Hydra::PCDM::File
  # @param [String, NilClass] filepath the cached file within the Hyrax.config.working_path
  def perform(file_set, file_id, filepath = nil)
    super
    file = Hyrax::WorkingDirectory.find_or_retrieve(file_id, file_set.id, filepath)
    File.delete(file)
  end
end
