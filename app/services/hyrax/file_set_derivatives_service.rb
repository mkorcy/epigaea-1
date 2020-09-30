# Patching FileSetsDerivativeService to do HLS and MPEG4 for video instead of MPEG4 and WEBM.
require_dependency Hyrax::Engine.root.join('app', 'services', 'hyrax', 'file_set_derivatives_service').to_s

module Hyrax
  class FileSetDerivativesService
    private

      def create_video_derivatives(filename)
        Hydra::Derivatives::VideoDerivatives.create(filename,
                                                    outputs: [
                                                      { label: :thumbnail, format: 'jpg', url: derivative_url('thumbnail') },
                                                      { label: 'hls', format: 'm3u8', url: derivative_url('m3u8') },
                                                      { label: 'mp4', format: 'mp4', url: derivative_url('mp4') }
                                                    ])
      end
  end
end
