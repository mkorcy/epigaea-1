# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require File.expand_path('../config/application', __FILE__)

Rails.application.load_tasks

task(:default).clear
task default: ['tufts:ci']

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

desc "update_object_index"
task update_object_index: :environment do
  puts "Loading File"
  CSV.foreach("/usr/local/hydra/epigaea/objects_to_update.csv", headers: false, header_converters: :symbol, encoding: "ISO8859-1:utf-8") do |row|
    pid = row[0]
    puts pid.to_s
    a = ActiveFedora::Base.find(pid, cast: true)
    a.update_index
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
