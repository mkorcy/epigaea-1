# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require File.expand_path('../config/application', __FILE__)
require 'byebug'

Rails.application.load_tasks

task(:default).clear
task default: ['tufts:ci']

desc "compute handles"
task compute_handles: :environment do
  puts "Loading File"
  CSV.foreach("/usr/local/hydra/epigaea/b.out", headers: false, header_converters: :symbol, encoding: "ISO8859-1:utf-8") do |row|
    pid = row[0]
    a = ActiveFedora::Base.find(pid)
    if a.empty?
      puts "NOPE #{pid}"
    else
      handles = a.first.identifier
      handles.each do |handle|
      handle = handle.gsub("http://hdl.handle.net/","")
      model = a.first.class.to_s
      case  model
      when "Image"
        model = 'images/'
      when "Pdf"
        model = 'pdfs/'
      when "Ead"
        model = 'eads/'
      when "Rcr"
        model = 'rcrs/'
      when "Audio"
        model = 'audios/'
      when "Video"
        model = 'videos/'
      when "GenericObject"
        model = 'generic_objects/'
      when "Tei"
        model = 'teis/'
      when "VotingRecord"
        model = 'voting_records/'
      else
        puts "NOPE NO MODEL FOUND #{model}"
      end
      url = 'https://dl.tufts.edu/conern/' + model + a.first.id
      puts "UPDATE handles set data='#{url}' WHERE handle='#{handle}' and type='URL';"
      end
    end
  end
end

desc "sipity updates"
task sipity_updates: :environment do
  puts "Loading File"
  CSV.foreach("/usr/local/hydra/epigaea/sipity_updates.txt", headers: false, header_converters: :symbol, encoding: "ISO8859-1:utf-8") do |row|
    begin
      pid = row[0]
      a = ActiveFedora::Base.find(pid)
      puts "insert into sipity_entities (proxy_for_global_id, workflow_id, workflow_state_id, created_at, updated_at) values ('gid://epigaea/#{a.class}/#{pid}',1,1, NOW(), NOW());"
    rescue ActiveFedora::ObjectNotFoundError
      puts "ERROR not found #{pid}"
    end
  end
end

desc "translate f3 pid to f4"
task f3_to_f4: :environment do
  puts "Loading File"
  CSV.foreach("/usr/local/hydra/epigaea/translate_pids.txt", headers: false, header_converters: :symbol, encoding: "ISO8859-1:utf-8") do |row|
    pid = row[0]
    a = ActiveFedora::Base.where(legacy_pid_tesim: pid)
    if a.empty?
      puts "NOPE #{pid}"
    else
      puts "YEP #{a.first.id}"
    end
  end
end


desc "check if fedora 3 pids are migrated"
task do_these_exist: :environment do
  puts "Loading File"
  CSV.foreach("/usr/local/hydra/epigaea/do_these_exist.txt", headers: false, header_converters: :symbol, encoding: "ISO8859-1:utf-8") do |row|
    pid = row[0]
    a = ActiveFedora::Base.where(legacy_pid_tesim: pid)
    if a.empty?
      puts "NOPE #{pid}"
    else
      puts "YEP #{pid}"
    end
  end
end

desc "set visibility"
task make_filesets_public: :environment do
  puts "Loading File"
  CSV.foreach("/usr/local/hydra/epigaea/file_sets.txt", headers: false, header_converters: :symbol, encoding: "ISO8859-1:utf-8") do |row|
    pid = row[0]
    a = FileSet.find(pid)
puts "ABOUT TO UPDATE : #{pid}"
    a.visibility = 'open'
    a.save!
  end
end


desc "apply embargos"
task apply_embargos: :environment do
  puts "Loading File"
  CSV.foreach("/usr/local/hydra/epigaea/embargos_to_apply.csv", headers: false, header_converters: :symbol, encoding: "ISO8859-1:utf-8") do |row|
    pid = row[0]
    release = row[1]
    puts pid.to_s
    a = ActiveFedora::Base.where(legacy_pid_tesim: pid)
    work = a.first unless a.nil?
    unless work.nil?
      work.visibility = Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC
      work.visibility_during_embargo = Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PRIVATE
      work.visibility_after_embargo = Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC
      work.embargo_release_date = release
      work.save
    end
    puts a.to_s
  end
end

desc "f3 updates"
task f3_updates: :environment do
  puts "Loading File"
  CSV.foreach("/usr/local/hydra/epigaea/f3_updates.txt", headers: false, header_converters: :symbol, encoding: "ISO8859-1:utf-8") do |row|
    id = row[0]
    updated = row[1]

    next if id.starts_with?('tufts:')
    id = id.gsub("draft:", "tufts:")
    puts "UPDATE select_ingest_dates set f3_edited_date='#{updated}' where legacy_pid_tesim='#{id}';"
  end
end

desc "iterate collections"
task iterate_and_fix_collections1: :environment do
  colls = Collection.all
  colls.each do |col|
    ead_id = col.ead
    ead_id = ead_id.to_a.first
    substring = "DO"
    ead_id = "" if ead_id.nil?
    count =  ead_id.scan(/(?=#{substring})/).count

    if count > 1
      ead_id = ead_id.sub(substring + ".", "")
      puts "FIX #{ead_id}"
      col.ead = [ead_id]
      col.save
    else
      puts "OK"
    end
  end
end

desc "apply genres"
task apply_genre: :environment do
  file = File.read('genre.json')
  data_hash = JSON.parse(file)
  data_hash["response"]["docs"].each do |doc|
    next if doc['genre_tesim'].nil? || doc['genre_tesim'].empty?
    id = doc['id'].gsub("draft:", "tufts:")
    obj = ActiveFedora::Base.where(legacy_pid_tesim: id)
    next if obj.empty?
    o = obj.first
    o.genre = doc['genre_tesim']
    o.save!
    puts "#{o.id} #{doc['genre_tesim']}"
  end
end

desc "iterate collections"
task iterate_and_fix_collections: :environment do
  colls = Collection.all
  colls.each do |col|
    ead_id = col.ead
    ead_id = ead_id.to_a.first
    puts "class #{ead_id.class}"
    eads = Ead.where(legacy_pid_tesim: ead_id)
    eads = eads.to_a.first unless eads.to_a.empty?
    if eads.instance_of? Ead
      eads.member_of_collections = [col]
      eads.save
      puts "Add #{eads} with legacy_pid (#{ead_id}) to #{col.id}"
    else
      puts "SKIPPING"
    end
  end
end

desc "update_fileset_index"
task update_fileset_index: :environment do
  puts "Loading File"
  CSV.foreach("/usr/local/hydra/epigaea/file_sets.txt", headers: false, header_converters: :symbol, encoding: "ISO8859-1:utf-8") do |row|
    pid = row[0]
    puts pid.to_s
    # puts "#{pid}"
    begin
      a = FileSet.find(pid)
      a.update_index
    rescue Ldp::HttpError
      puts "ERROR on #{pid}"
    rescue ActiveFedora::ObjectNotFoundError
      puts "ERROR not found #{pid}"
    end
  end
end

desc "update_object_index"
task update_object_index: :environment do
  puts "Loading File"
  CSV.foreach("/usr/local/hydra/epigaea/objects_to_update.csv", headers: false, header_converters: :symbol, encoding: "ISO8859-1:utf-8") do |row|
    pid = row[0]
    puts pid.to_s
    begin
      a = ActiveFedora::Base.find(pid, cast: true)
      a.update_index
    rescue Ldp::HttpError
      puts "ERROR on #{pid}"
    rescue ActiveFedora::ObjectNotFoundError
      puts "ERROR on #{pid}"
    end
  end
end

desc "get class for objects"
task get_class_for_objects: :environment do
  puts "Loading File"
  CSV.foreach("/usr/local/hydra/epigaea/class.csv", headers: false, header_converters: :symbol, encoding: "ISO8859-1:utf-8") do |row|
    pid = row[0]
    puts pid.to_s
    a = ActiveFedora::Base.find(pid)
    puts "insert into sipity_entities (proxy_for_global_id, workflow_id, workflow_state_id, created_at, updated_at) values ('gid://epigaea/#{a.class}/#{a.id}/',1,1, NOW(), NOW());"
  end
end
desc "put object in workflow"
task put_objects_in_workflow: :environment do
  puts "Loading File"
  CSV.foreach("/usr/local/hydra/epigaea/objects_in_workflow.csv", headers: false, header_converters: :symbol, encoding: "ISO8859-1:utf-8") do |row|
    pid = row[0]
    puts pid.to_s
    object = ActiveFedora::Base.where(legacy_pid_tesim: pid)

    if object.empty?
      raise "object missing #{pid}"
    else
      object = object.first
    end

    user = User.find_by(username: 'migration')
    subject = Hyrax::WorkflowActionInfo.new(object, user)

    begin
      Hyrax::Workflow::WorkflowFactory.create(object, {}, user)
    rescue ActiveRecord::RecordNotUnique
      puts "Already in Workflow"
    end
    tries = 20
    begin
      object = object.reload
      sipity_workflow_action = PowerConverter.convert_to_sipity_action("publish", scope: subject.entity.workflow) { nil }
      Hyrax::Workflow::WorkflowActionService.run(subject: subject, action: sipity_workflow_action, comment: "Migrated from Fedora 3")
    rescue NoMethodError
      tries -= 1
      if tries > 0
        sleep(5.seconds)
        retry
      else
        Rails.logger.error "Fixture file missing original for"
      end
    end
  end
end
