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

  desc "Recreate derivatives for all Videos"
  task recreate_all_videos: :environment do
    puts ''
    file_set_id_list.each do |id|
      fs = FileSet.find(id)
      asset_path = fs.original_file.uri.to_s
      asset_path = asset_path[asset_path.index(fs.id.to_s)..-1]
      RecreateVideoDerivativesJob.perform_later(fs, asset_path)
    end
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

  def file_set_id_list
    [
      'q237j469n',
      'mk61rv596',
      'jd473878t',
      'z029ph858',
      'bc386w87s',
      'm326mc97b',
      'r494vx27t',
      'rr172922k',
      'p55483399',
      'xg94j254v',
      'r781ws62f',
      'zk51vv13b',
      'br86bf971',
      'gh93h982s',
      'g158bv52t',
      '05742338h',
      'wh247627j',
      'bg257t282',
      'rj430h543',
      'mk61rw40p',
      'fx71b0881',
      'nv935f77w',
      '9g54xx03d',
      'rr172b100',
      'cj82km64s',
      'bn999n23m',
      'br86bg73n',
      'jw827q56v',
      '8s45qp185',
      'd791sv56z',
      'hm50v5289',
      'n87104393',
      's7526r582',
      '70795n29z',
      'th83m987x',
      '7w62fn54d',
      'np193p69z',
      'n296xb99x',
      'j9602c40c',
      'qv33s878p',
      'k643bd311',
      'v405sp68k',
      'tt44q0818',
      'kp78gv14q',
      'qz20t5621',
      'f7623r61m',
      '5m60r430c',
      '3197z0147',
      '9k41zs47h',
      'c534g199v',
      '6d5709214',
      '6d5708960',
      'r207v2601',
      'h989rf779',
      '02871762j',
      'qn59qg58q',
      'x633fd12k'
    ]
  end

end
