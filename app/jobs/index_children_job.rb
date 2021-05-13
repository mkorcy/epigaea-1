##
# A job to register handles and save it to the object.
#
# @example
#   object = Pdf.create(title: ['Moomin'])
#   HandleRegisterJob.perform_later(object)
#
# @see ActiveJob::Base, HandleDispatcher.assign_for!
class IndexChildrenJob < ApplicationJob
  unique :until_executed

  queue_as :collection_indexer

  ##
  def perform(children)
    children.each do |child|
      reindex_nested_relationships_for(id: child, extent: Hyrax::Adapters::NestingIndexAdapter::LIMITED_REINDEX)
    end
  end

  private

    def reindex_nested_relationships_for(id:, extent:)
      Hyrax.config.nested_relationship_reindexer.call(id: id, extent: extent)
    end
end
