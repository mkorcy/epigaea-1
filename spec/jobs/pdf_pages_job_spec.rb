# frozen_string_literal: true

require 'rails_helper'

describe PdfPagesJob do
  let(:user) { create(:user) }
  subject(:job) { described_class }

  let(:file_set) do
    create(:file_set, user: user).tap do |file|
      Hydra::Works::AddFileToFileSet.call(file, File.open(fixture_path + '/hello.pdf'), :original_file, versioning: true)
    end
  end
  let(:file_id) { file_set.original_file.id }
  before { ActiveJob::Base.queue_adapter = :test }

   describe '#perform_later' do
     it 'enqueues the job' do
       expect { job.perform_later(file_set) }
         .to enqueue_job(described_class)
         .on_queue('ingest')
     end
   end
end
