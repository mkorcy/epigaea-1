require 'rake'

namespace :tufts do
  desc "Reindex VotingRecords that don't have the iiif_page_images_ssim field"
  task reindex_non_iiif_voting_records: :environment do
    VotingRecord.find_each do |v|
      solr_doc = SolrDocument.find(v.id)
      iiif = solr_doc["iiif_page_images_ssim"]
      if iiif.nil? || iiif.empty?
        begin
                puts "Reindexing: #{v.id}"
                v.update_index
              rescue StandardError => e
                puts e.message
              end
      else
        puts "#{v.id} ok: #{iiif}"
      end
    end
  end
end
