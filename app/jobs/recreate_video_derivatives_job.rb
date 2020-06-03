class RecreateVideoDerivativesJob < CreateDerivativesJob
  queue_as(:batch_recreate_video_derivatives)
end