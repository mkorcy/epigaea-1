##
# A job to register handles and save it to the object.
#
# @example
#   object = Pdf.create(title: ['Moomin'])
#   HandleRegisterJob.perform_later(object)
#
# @see ActiveJob::Base, HandleDispatcher.assign_for!
class PdfPagesJob < ApplicationJob
  queue_as Hyrax.config.ingest_queue_name

  ##
  # @param object [ActiveFedora::Base]
  def perform(object)
    Tufts::PdfPages.new.convert_to_png(object)
  end
end
