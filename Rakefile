# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require File.expand_path('../config/application', __FILE__)
require 'byebug'
require 'fileutils'

Rails.application.load_tasks

task(:default).clear
task default: ['tufts:ci']
desc "apply changes from f3"

task apply_changes: :environment do
  file = File.read('updates.json')
  data_hash = JSON.parse(file)
  data_hash.each do |obj|
    pid = obj["pid"]
    change = obj["subject"]
    a = ActiveFedora::Base.where(legacy_pid_tesim: pid)
    if a.empty?
      puts "NOPE #{pid}"
    else
      fedora_object = a.first
      fedora_object.subject = change
      fedora_object.save!
    end
  end
end
desc "check_if_exists"
task check_if_exists: :environment do
  puts "Loading File"
  logger = Logger.new('log/exists.log')
  CSV.foreach("/usr/local/hydra/epigaea/exists.txt", headers: false, header_converters: :symbol, encoding: "ISO8859-1:utf-8") do |row|
    found = false
    pid = row[0]
    a = ActiveFedora::Base.where(legacy_pid_tesim: pid)
    if a.empty?
      pid = pid.gsub("draft:", "tufts:")
      a = ActiveFedora::Base.where(legacy_pid_tesim: pid)
      found = true unless a.empty?
    else
      found = true
    end

    logger.info "FOUND #{pid}" if found
    logger.info "ERROR #{pid}" unless found
  end
end

desc "apply_embargos"
task apply_embargos: :environment do
  puts "Loading File"
  CSV.foreach("/usr/local/hydra/epigaea/apply_embargos.txt", headers: false, header_converters: :symbol, encoding: "ISO8859-1:utf-8") do |row|
    begin
      pid = row[1]
      embargo = row[0]
      a = ActiveFedora::Base.find(pid)
      a.visibility = 'restricted'
      a.visibility_during_embargo = 'restricted'
      a.visibility_after_embargo 'open'
      a.embargo_release_date = embargo
      a.save!
    rescue ActiveFedora::RecordInvalid
      a.visibility = 'open'
      a.deactivate_embargo!
      a.embargo.save
      a.save!
    rescue ActiveFedora::ObjectNotFoundError
      puts "ERROR not found #{pid}"
    end
  end
end

desc "scattering"
task scattering: :environment do
  puts "Loading File"
  CSV.foreach("/usr/local/hydra/epigaea/scattering.txt", headers: false, header_converters: :symbol, encoding: "ISO8859-1:utf-8") do |row|
    begin
      pid = row[0]
      a = ActiveFedora::Base.find(pid)
      names = a.personal_name
      names.delete("scattering")
      subjects = a.subject
      subjects.push("Scattering votes")
      a.subject = subjects
      a.personal_name = names
      a.save!
    rescue ActiveFedora::ObjectNotFoundError
      puts "ERROR not found #{pid}"
    end
  end
end

desc "strip subjects"
task strip_subjects: :environment do
  puts "Loading File"
  CSV.foreach("/usr/local/hydra/epigaea/strip_subjects.txt", headers: false, header_converters: :symbol, encoding: "ISO8859-1:utf-8") do |row|
    begin
      pid = row[0]
      a = ActiveFedora::Base.find(pid)
      a.subject = []
      a.save!
    rescue ActiveFedora::ObjectNotFoundError
      puts "ERROR not found #{pid}"
    end
  end
end

# rubocop:disable Lint/AmbiguousRegexpLiteral
def sanitize_filename(filename)
  # Split the name when finding a period which is preceded by some
  # character, and is followed by some character other than a period,
  # if there is no following period that is followed by something
  # other than a period (yeah, confusing, I know)
  fn = filename.split /(?<=.)\.(?=[^.])(?!.*\.[^.])/m

  # We now have one or two parts (depending on whether we could find
  # a suitable period). For each of these parts, replace any unwanted
  # sequence of characters with an underscore
  fn.map! { |s| s.gsub /[^a-z0-9\-]+/i, '_' }

  # Finally, join the parts with a period and return the result
  fn.join '.'
end
desc "chronopolis"
task chronopolis: :environment do
  logger = Logger.new('log/chronopolis.log')

  CSV.foreach("/usr/local/hydra/epigaea/chronopolis.txt", headers: false, header_converters: :symbol, encoding: "ISO8859-1:utf-8") do |row|
    pid = row[0]
    begin
      logger.info "PROCESSING PID : #{pid}"
      obj = ActiveFedora::Base.find(pid)

      # get steward for top directory
      steward = obj.steward
      steward = if steward.nil? || steward.empty?
                  "no_steward"
                else
                  steward
                end
      steward = sanitize_filename(steward)

      logger.info "Steward for #{pid} is #{steward}"

      # get collection for object
      collections = obj.member_of_collections
      collection = ""
      if collections.nil? || collections.empty?
        collection = "uncollected"
      else
        collection_titles = []
        collection_ids = []

        collections.each do |collection_inner|
          collection_titles << collection_inner.title.first
          collection_ids << collection_inner.id
        end

        index = collection_titles.index("Collection Descriptions")
        saved_index = 0
        if !index.nil? && collection_titles.length > 1
          collection_titles.delete("Collection Descriptions")
          saved_index = index > 0 ? 0 : 1
        end
        puts "COL TITLES : #{collection_titles}"

        index = collection_titles.index("Electronic Theses and Dissertations")
        collection = if index.nil?
                       collections[saved_index].id + "_" + collections[saved_index].title.first
                     else
                       collection_ids[index] + "_" + "Electronic Theses and Dissertations"
                     end

        collection = collection.truncate(255)
        collection = sanitize_filename(collection)

      end

      logger.info "Collection for #{pid} is #{collection}"

      # mkdir for object

      obj_dir = obj.id + "_" + obj.title.first
      obj_dir = obj_dir.truncate(255)
      obj_dir = sanitize_filename(obj_dir)

      FileUtils.mkdir_p File.join('/', 'tdr', 'chronopolis', steward, collection, obj_dir)

      # mkdirs for filesets
      obj.file_sets.each do |file_set|
        target_filename = file_set.id + "_" + file_set.title.first
        target_filename = target_filename.truncate(255)
        target_filename = sanitize_filename(target_filename)
        FileUtils.mkdir_p File.join('/', 'tdr', 'chronopolis', steward, collection, obj_dir, target_filename)
        target_file = File.join('/', 'tdr', 'chronopolis', steward, collection, obj_dir, target_filename, target_filename)
        metadata_file = File.join('/', 'tdr', 'chronopolis', steward, collection, obj_dir, target_filename, "technical_metadata.json")

        record = File.new target_file, 'wb'

        logger.info "Writing fileset to #{target_file}"

        record.write file_set.original_file.content
        record.flush
        record.close

        json = JSON.parse(file_set.characterization_proxy.metadata.attributes.to_json)
        json = JSON.pretty_generate(json)
        metadata = File.new metadata_file, "w"

        logger.info "Writing metadata to #{metadata_file}"

        metadata.write json
        metadata.flush
        metadata.close
      end

      # write out metadata
      json = JSON.parse(obj.to_json)
      json = JSON.pretty_generate(json)
      metadata_file = File.join('/', 'tdr', 'chronopolis', steward, collection, obj_dir, "metadata.json")
      metadata = File.new metadata_file, "w"

      logger.info "Writing metadata to #{metadata_file}"

      metadata.write json
      metadata.flush
      metadata.close
    rescue ActiveFedora::ObjectNotFoundError
      puts "ERROR not found #{pid}"
      logger.error "ERROR Pid not found #{pid}"
      next
    rescue Ldp::Gone
      puts "ERROR not found #{pid}"
      logger.error "ERROR Pid not found #{pid}"
      next
    end
  end
end

desc "compute handles2"
task compute_handles2: :environment do
  puts "Loading File"
  CSV.foreach("/usr/local/hydra/epigaea/book.txt", headers: false, header_converters: :symbol, encoding: "ISO8859-1:utf-8") do |row|
    pid = row[3]
    handle_id = row[0]

    a = ActiveFedora::Base.where(legacy_pid_tesim: pid)
    if a.empty?
      puts "NOPE #{pid}"
    else
      handles = a.first.identifier
      handles.each do |_handle|
        # handle = handle.gsub("http://hdl.handle.net/", "")
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
        puts "UPDATE handles set data='#{url}' WHERE handle='#{handle_id}' and type='URL';"
      end
    end
  end
end

desc "compute handles"
task compute_handles: :environment do
  puts "Loading File"
  CSV.foreach("/usr/local/hydra/epigaea/b.out", headers: false, header_converters: :symbol, encoding: "ISO8859-1:utf-8") do |row|
    pid = row[0]
    a = ActiveFedora::Base.where(legacy_pid_tesim: pid)
    if a.empty?
      puts "NOPE #{pid}"
    else
      handles = a.first.identifier
      handles.each do |handle|
        handle = handle.gsub("http://hdl.handle.net/", "")
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

desc "collection by title"
task collection_by_title: :environment do
  puts "Loading File"
  CSV.foreach("/usr/local/hydra/epigaea/collect_items.csv", headers: false, header_converters: :symbol, encoding: "ISO8859-1:utf-8") do |row|
    pid = row[0]
    title = row[1]
    begin
      puts "PROCESSING PID : #{pid}"
      obj = ActiveFedora::Base.find(pid)
      if obj.class.to_s == "Ead"
        puts "FOUND EAD NEXT"
        next
      end

      col = Collection.find(title)
      obj.member_of_collections = [col]
      obj.save!
    rescue ActiveFedora::ObjectNotFoundError
      puts "ERROR not found #{pid} #{title}"
    end
  end
end

desc "add to collection"
task add_to_collection_descriptions: :environment do
  puts "Loading File"
  CSV.foreach("/usr/local/hydra/epigaea/eads.txt", headers: false, header_converters: :symbol, encoding: "ISO8859-1:utf-8") do |row|
    begin
      pid = row[0]
      obj = ActiveFedora::Base.find(pid)
      col = Collection.find("vd66vz89n")

      obj.member_of_collections << col

      obj.save!
    rescue ActiveFedora::ObjectNotFoundError
      puts "ERROR not found #{pid}"
    end
  end
end

desc "ead matching"
task ead_matching: :environment do
  puts "Loading File"
  CSV.foreach("/usr/local/hydra/epigaea/eads.txt", headers: false, header_converters: :symbol, encoding: "ISO8859-1:utf-8") do |row|
    begin
      pid = row[0]
      title = row[1]
      obj = ActiveFedora::Base.find(pid)
      cols = Collection.where(title_tesim: title)
      col_desc = Collection.find('vd66vz89n')

      if cols.empty?
        puts "EAD #{pid} has no matching collection"
        a = Collection.new(title: [title])
        a.apply_depositor_metadata 'apruit01'
        a.visibility = Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC
        a.save!
        a = a.reload
        obj.member_of_collections = [a, col_desc]
      else
        puts "EAD #{pid} has a matching collection and can be added."
        col = cols.first
        obj.member_of_collections = [col, col_desc]
      end

      obj.save!
    rescue ActiveFedora::ObjectNotFoundError
      puts "ERROR not found #{pid}"
    end
  end
end

desc "publish objects"
task publish_objects: :environment do
  puts "Loading File"
  CSV.foreach("/usr/local/hydra/epigaea/publish_objects.txt", headers: false, header_converters: :symbol, encoding: "ISO8859-1:utf-8") do |row|
    begin
      pid = row[0]
      # a = ActiveFedora::Base.find(pid)
      PublishJob.perform_later(pid)
    rescue ActiveFedora::ObjectNotFoundError
      puts "ERROR not found #{pid}"
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
      puts "insert into sipity_entities (proxy_for_global_id, workflow_id, workflow_state_id, created_at, updated_at) values ('gid://epigaea/#{a.class}/#{pid}',1,2, NOW(), NOW());"
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
      puts "DUPE DUPE DUPE #{a} #{pid}" if a.length > 1
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

      a = ActiveFedora::Base.where(legacy_pid_tesim: pid.gsub("tufts:", "draft:"))
      if a.empty?
        puts "NOPE #{pid}"
      else
        pid = pid.gsub("tufts:", "draft:")
        puts "YEP #{pid}"
      end
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
task apply_embargos_by_f4_ids: :environment do
  puts "Loading File"
  CSV.foreach("/usr/local/hydra/epigaea/embargos_to_apply.csv", headers: false, header_converters: :symbol, encoding: "ISO8859-1:utf-8") do |row|
    pid = row[0]
    release = row[1]
    puts pid.to_s
    a = ActiveFedora::Base.find(pid)
    work = a
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
