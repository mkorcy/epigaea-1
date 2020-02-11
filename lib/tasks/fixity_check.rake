# frozen_string_literal: true

namespace :tdr do
  desc 'Starts fixity check on all files with random sampling 6000'
  task fixity_check: :environment do
    ::Hyrax::RepositoryFixityCheckService.fixity_check_random_sampling
  end
  desc 'Starts fixity monthly catchup job'
  task fixity_monthly: :environment do
    ::Hyrax::RepositoryFixityCheckService.fixity_monthly_catchup
  end
  nd
end
