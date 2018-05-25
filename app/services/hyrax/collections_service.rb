# @file
# Monkey patch for Collections List

require_dependency Hyrax::Engine.root.join('app', 'services', 'hyrax', 'collections_service').to_s

module Hyrax
  class CollectionsService
    private

      def list_search_builder(access)
        # Shows all collections instead of just 100
        list_search_builder_class.new(context).rows(Collection.count).tap do |builder|
          builder.discovery_permissions = [access]
        end
      end
  end
end
