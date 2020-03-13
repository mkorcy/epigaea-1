module Hyrax
  module Workflow
    # Notification of state change to "approved".
    # Should notify users with the approving role for the work's AdminSet, plus super users.
    # This notification is sent by the workflow.
    class PublishedNotification < MiraWorkflowNotification
      def workflow_recipients
        { "to" => (admins << depositor) }
      end

      def subject
        "Deposit #{title} has been published"
      end

      def message
        "Your submission \"#{title}\" is now available in the Tufts Digital library. Here is the link to access it: #{handle}.<br/><br/>" \
          "If you have any questions about this submission, please contact us at #{contact_email}." +
          (embargo? ? "<br/><br/>Note: This item is under embargo and may not be yet available when you receive this message." : "")
      end
    end
  end
end
