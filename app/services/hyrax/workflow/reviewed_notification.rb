module Hyrax
  module Workflow
    class ReviewedNotification < AbstractNotification
      private

      def subject
        'Deposit reviewed and ready for publication'
      end

      def message
        "#{title} (#{link_to work_id, document_path}) was reviewed by #{user.user_key} and is awaiting publication #{comment}"
      end

      def users_to_notify
        super << user
      end
    end
  end
end