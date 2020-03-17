# frozen_string_literal: true

namespace :tdr do
  desc 'Starts fixity check on all files'
  task fixity_check: :environment do
    ::Hyrax::RepositoryFixityCheckService.fixity_check_random_sampling
  end

  desc 'fixity everything'
  task fixity_everything: :environment do
    ::Hyrax::RepositoryFixityCheckService.fixity_check_everything
  end

  desc 'run fixity for a particular id'
  task :fixity_by_id, [:id] => :environment do |_task, args|
    fs_id = args[:id]
    raise "ERROR: no work id specified, aborting" if fs_id.nil?
    ::Hyrax::RepositoryFixityCheckService.fixity_check_fileset(fs_id)
    puts "Fixity checked for fileset id #{fs_id}"
  end
end
