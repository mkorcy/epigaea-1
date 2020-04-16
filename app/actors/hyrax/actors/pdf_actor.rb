module Hyrax
  module Actors
    class PdfActor < ApplicationModelActor
      def self.create_pdf_pages(object:)
        PdfPagesJob.perform_later(object.id)

        true
      end

      ##
      # @param env [Hyrax::Actors::Enviornment]
      #
      # @return [Boolean]
      def create(env)
        next_actor.create(env) && create_pdf_pages(object: env.curation_concern)
      end

      ##
      # @param env [Hyrax::Actors::Enviornment]
      #
      # @return [Boolean]
      def update(env)
        next_actor.update(env) && create_pdf_pages(object: env.curation_concern)
      end

      ##
      # @see PdfActor.create_pdf_pages
      def create_pdf_pages(object:)
        self.class.create_pdf_pages(object: object)
      end
    end
  end
end
