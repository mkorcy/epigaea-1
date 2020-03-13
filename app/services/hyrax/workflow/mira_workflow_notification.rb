module Hyrax
  module Workflow
    class MiraWorkflowNotification < AbstractNotification
      # regardless of what is passed in, set the recipients according to this notification's requirements
      def initialize(entity, comment, user, recipients)
        super
        @recipients = workflow_recipients.with_indifferent_access
        # @work = ::TuftsModel.find(document.id)
        @work = ActiveFedora::Base.find(document.id, cast: true)
      end

      def workflow_recipients
        raise NotImplementedError, "Implement workflow_recipients in a child class"
      end

      # The Users who have an admin role
      # @return [<Array>::User] an Array of Hyrax::User objects
      def admins
        Role.where(name: 'admin').first_or_create.users.to_a
      end

      # The Hyrax::User who desposited the work
      # @return [Hyrax::User]
      def depositor
        ::User.find_by_user_key(document.depositor)
      end

      def handle
        handle = @work.identifier.empty? ? nil : @work.identifier.first
      end

      def embargo?
        @work.embargo ? true : false
      end

      def contact_email
        steward = @work.steward
        tisch_email = 'metadataservices@tufts.edu'
        dca_email = 'archives@tufts.edu'
        if steward == 'dca'
          dca_email
        else
          tisch_email
        end
      end

      ##
      # A fully qualified url to the document
      def document_url
        key = document.model_name.singular_route_key
        Rails.application.routes.url_helpers.send(key + "_url", document.id)
      end
    end
  end
end
