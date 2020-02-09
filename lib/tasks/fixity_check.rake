# frozen_string_literal: true

namespace :tdr do
  desc 'Starts fixity check on all files'
  task fixity_check: :environment do
    ::Hyrax::RepositoryFixityCheckService.fixity_check_random_sampling
  end
end
