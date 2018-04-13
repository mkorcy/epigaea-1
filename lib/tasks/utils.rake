require 'active_fedora/cleaner'

desc "Tufts Utility Tasks"
namespace :tufts do
  desc "Delete all the content in Fedora 4"
  task clean4: :environment do
    ActiveFedora::Cleaner.clean!
  end

  desc "initialize mira-data dirs"
  task init_data_dirs: :environment do
  end

  desc "clean data dirs"
  task clean_data_dirs: :environment do
    base_dir = "/usr/local/hydra/mira-data/current"
    cache_dir = "cache"
    deriv_dir = "derivatives"
    drafts_dir = "drafts"
    exports_dir = "exports"
    templates_dir = "templates"
    uploads_dir = "uploads"
    all_dirs = [cache_dir, deriv_dir, drafts_dir, exports_dir, templates_dir, uploads_dir]
    all_dirs.map! { |dir| "#{base_dir}/#{dir}/*" }
    all_dirs.each { |dir| FileUtils.rm_rf(Dir.glob(dir)) }
    # all_dirs.each { |dir| print "Delete #{dir}\n" }
  end
end
