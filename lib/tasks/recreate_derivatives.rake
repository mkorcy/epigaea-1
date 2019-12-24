namespace :derivatives do
  desc "Recreate derivatives for all Pdfs"
  task recreate_all_pdfs: :environment do
    count = 0
    Pdf.all.each do |pdf|
      recreate_derivatives(pdf)
      count += 1
    end
    puts "Recreated derivatives for #{count} pdfs(s)"
  end

  desc "Recreate derivatives for specified work, e.g., rake derivatives:recreate_by_id['c821gj76b']"
  task :recreate_by_id, [:id] => :environment do |_task, args|
    work_id = args[:id]
    raise "ERROR: no work id specified, aborting" if work_id.nil?
    work = ActiveFedora::Base.find(work_id)
    raise "ERROR: work #{work_id} does not exist, aborting" if work.nil?
    recreate_derivatives(work)
    puts "Recreated derivatives for work id #{work.id}"
  end

  desc "Recharacterize a specified work from a list, e.g., rake derivatives:recharacterize_by_id[/path/to/list.csv]"
  task :recharacterize_by_list, [:list] => :environment do |_task, args|
    list_path = args[:id]
    CSV.foreach(list_path, headers: false, header_converters: :symbol, encoding: "ISO8859-1:utf-8") do |row|
      work_id = row[0]
      raise "ERROR: no work id specified, aborting" if work_id.nil?
      work = ActiveFedora::Base.find(work_id)
      raise "ERROR: work #{work_id} does not exist, aborting" if work.nil?
      recharacterize_work(work)
      puts "Recreated derivatives for work id #{work.id}"
    end
  end

  desc "Recharacterize a specified work from a list, e.g., rake derivatives:recharacterize_by_list_of_filesets[/path/to/list.csv]"
  task :recharacterize_by_list_of_filesets, [:list] => :environment do |_task, args|
    list_path = args[:list]
    CSV.foreach(list_path, headers: false, header_converters: :symbol, encoding: "ISO8859-1:utf-8") do |row|
      fileset_id = row[0]
      raise "ERROR: no work id specified, aborting" if fileset_id.nil?
      fileset = FileSet.find(fileset_id)
      raise "ERROR: work #{fileset_id} does not exist, aborting" if fileset.nil?
      recharacterize_fileset(fileset)
      puts "Recreated derivatives for work id #{fileset.id}"
    end
  end

  desc "Recharacterize a specified work, e.g., rake derivatives:recharacterize_by_id['c821gj76b']"
  task :recharacterize_by_id, [:id] => :environment do |_task, args|
    work_id = args[:id]
    raise "ERROR: no work id specified, aborting" if work_id.nil?
    work = ActiveFedora::Base.find(work_id)
    raise "ERROR: work #{work_id} does not exist, aborting" if work.nil?
    recharacterize_work(work)
    puts "Recreated derivatives for work id #{work.id}"
  end

  # helpers
  #
  def recreate_derivatives(work)
    puts "Recreating derivatives for work #{work.id}"
    work.file_sets.each do |fs|
      puts " processing file set #{fs.id}"
      asset_path = fs.original_file.uri.to_s
      asset_path = asset_path[asset_path.index(fs.id.to_s)..-1]
      CreateDerivativesJob.perform_later(fs, asset_path)
    end
  end

  def recharacterize_fileset(fileset)
    fs = fileset
    puts " processing file set #{fs.id}"
    asset_path = fs.original_file.uri.to_s
    asset_path = asset_path[asset_path.index(fs.id.to_s)..-1]
    CharacterizeJob.perform_later(fs, asset_path)
  end

  def recharacterize_work(work)
    puts "Recreating derivatives for work #{work.id}"
    work.file_sets.each do |fs|
      puts " processing file set #{fs.id}"
      asset_path = fs.original_file.uri.to_s
      asset_path = asset_path[asset_path.index(fs.id.to_s)..-1]
      CharacterizeJob.perform_later(fs, asset_path)
    end
  end
end
