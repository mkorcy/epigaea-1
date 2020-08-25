# Patching FileSetsController to send a clear_image_cache message to the TDL when a Image gets a new version
require_dependency Hyrax::Engine.root.join('app', 'controllers', 'hyrax', 'file_sets_controller').to_s

module Hyrax
  class FileSetsController < ApplicationController
    ##
    # Patch method to send the clear_image_cache directive to TDL when a binary is updated.
    def update
      if attempt_update
        send_image_cache_clear(params[:id]) if tdl_url.present?
        after_update_response
      else
        after_update_failure_response
      end
    rescue RSolr::Error::Http => error
      flash[:error] = error.message
      logger.error "FileSetsController::update rescued #{error.class}\n\t#{error.message}\n #{error.backtrace.join("\n")}\n\n"
      render action: 'edit'
    end

    private

      ##
      # Sends the file_set_id to the TDL so it can clear the image cache.
      # @param {str} file_set_id
      #   The id of the FileSet.
      def send_image_cache_clear(file_set_id)
        url = "#{tdl_url}/image_cache_clear"
        Faraday.post(url, "{ \"id\": \"#{file_set_id}\" }", 'Content-Type' => 'application/json')
      end

      ##
      # Get the TDL url from config/tufts.yml
      # @param {str} file_set_id
      #   The id of the FileSet.
      def tdl_url
        file = Rails.root.join('config', 'tufts.yml').to_s
        @tdl_url ||= YAML.safe_load(File.open(file)).deep_symbolize_keys![Rails.env.to_sym][:tdl_url]
      rescue
        ''
      end
  end
end
