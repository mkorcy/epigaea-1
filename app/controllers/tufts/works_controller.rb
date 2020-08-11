module Tufts
  class WorksController < ApplicationController
    include Hyrax::WorksControllerBehavior
    include Hyrax::BreadcrumbsForWorks
    include Tufts::Drafts::Editable

    before_action :redirect_non_admins

    def create
      super
      Hyrax::Workflow::SelfDepositNotification.new(curation_concern).call
    end

    def update
      delete_draft(params)
      super
    end

    private

      def redirect_non_admins
        redirect_to root_url unless current_user && (current_user.admin? || current_user.read_only?)
      end

      def delete_draft(params)
        work = ActiveFedora::Base.find(params['id'])
        work.delete_draft
      end
  end
end
