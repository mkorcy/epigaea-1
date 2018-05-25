module Tufts
  module TuftsHelperBehavior
    # @return [String] only search the catalog, not dashboard
    def search_form_action
      main_app.search_catalog_path
    end

    def workflow_status(model)
      Hyrax::PresenterFactory.build_for(ids: [model.id],
                                        presenter_class: "Hyrax::#{model.class}Presenter".classify.safe_constantize,
                                        presenter_args: nil)[0].solr_document["workflow_state_name_ssim"]
    end

    # Gets all this user's collections, sorted alphabetically.
    # In use in _form_for_select_collection.html.erb
    def alpha_user_collections
      @user_collections.sort do |c1, c2|
        c1[:title_tesim].first.downcase <=> c2[:title_tesim].first.downcase
      end
    end
  end
end
