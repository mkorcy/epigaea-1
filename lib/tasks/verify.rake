require 'digest'

namespace :tufts do
  # rubocop:disable Lint/AmbiguousRegexpLiteral
  def sanitize_filename(filename)
    fn = filename.split /(?<=.)\.(?=[^.])(?!.*\.[^.])/m

    fn.map! { |s| s.gsub /[^a-z0-9\-]+/i, '_' }

    fn.join '.'
  end

  def get_file_from_source(source, index)
    return nil if source.nil?

    return nil if source.ordered_file_sets[index].nil?

    target_file = source.ordered_file_sets[index].label
    target_file = sanitize_filename(target_file)
    puts "#{source.id} target #{index}: " + target_file
    # /tdr/chronopolis/f4_binaries
    voting_record = File.new("/tdr/chronopolis/f4_binaries/" + target_file, 'wb')
    voting_record.write source.ordered_file_sets[index].original_file.content
    voting_record.flush
    voting_record.close
    File.new("/tdr/chronopolis/f4_binaries/" + target_file)
  end

  def delete_dl_file(source, index)
    target_file = source.file_sets[index].label
    FileUtils.rm(target_file)
  end

  namespace :fedora do
    desc 'verify objs'
    task verify_video: :environment do
      csv = CSV.open("verify.csv", "w")
      puts "Re-indexing Fedora Repository."
      puts "Fedora Solr URL: #{ActiveFedora.solr_config[:url]}"
      CSV.foreach(ENV['INDEX_LIST']) do |row|
        pid = row[0]
        # obj = ActiveFedora::Base.find(pid, cast: true)
        obj = ActiveFedora::Base.where('legacy_pid_tesim: "' + pid + '"')

        datastream_file = get_file_from_source(obj.first, 0)
        unless datastream_file.nil?
          verification = ""
          verification = "object integrity issue" if obj.length != 1
          md5 = Digest::MD5.file datastream_file.path
          verification = md5.hexdigest if obj.length == 1
          csv << [obj.first.id, obj.first.legacy_pid, 'Archival Video', verification]
        end

        datastream_file = get_file_from_source(obj.first, 1)
        unless datastream_file.nil?
          verification = ""
          verification = "object integrity issue" if obj.length != 1
          md5 = Digest::MD5.file datastream_file.path
          verification = md5.hexdigest if obj.length == 1
          csv << [obj.first.id, obj.first.legacy_pid, 'Transcript', verification]
        end
      end
      puts "Solrizer task complete."
    end

    desc 'verify objs'
    task verify_audio: :environment do
      csv = CSV.open("verify.csv", "w")
      puts "Re-indexing Fedora Repository."
      puts "Fedora Solr URL: #{ActiveFedora.solr_config[:url]}"
      CSV.foreach(ENV['INDEX_LIST']) do |row|
        pid = row[0]
        # obj = ActiveFedora::Base.find(pid, cast: true)
        obj = ActiveFedora::Base.where('legacy_pid_tesim: "' + pid + '"')

        datastream_file = get_file_from_source(obj.first, 0)
        unless datastream_file.nil?
          verification = ""
          verification = "object integrity issue" if obj.length != 1
          md5 = Digest::MD5.file datastream_file.path
          verification = md5.hexdigest if obj.length == 1
          csv << [obj.first.id, obj.first.legacy_pid, 'Archival Audio', verification]
        end

        datastream_file = get_file_from_source(obj.first, 1)
        unless datastream_file.nil?
          verification = ""
          verification = "object integrity issue" if obj.length != 1
          md5 = Digest::MD5.file datastream_file.path
          verification = md5.hexdigest if obj.length == 1
          csv << [obj.first.id, obj.first.legacy_pid, 'Transcript', verification]
        end
      end
      puts "Solrizer task complete."
    end

    desc 'verify objs'
    task verify_pdfs: :environment do
      csv = CSV.open("verify.csv", "w")
      puts "Re-indexing Fedora Repository."
      puts "Fedora Solr URL: #{ActiveFedora.solr_config[:url]}"
      CSV.foreach(ENV['INDEX_LIST']) do |row|
        pid = row[0]
        # obj = ActiveFedora::Base.find(pid, cast: true)
        obj = ActiveFedora::Base.where('legacy_pid_tesim: "' + pid + '"')
        next if obj.first.nil?
        obj = ActiveFedora::Base.find(obj.first.id)
        datastream_file = get_file_from_source(obj, 0)
        unless datastream_file.nil?
          md5 = Digest::MD5.file datastream_file.path
          verification = md5.hexdigest
          csv << [obj.id, obj.legacy_pid, 'pdf', verification]
          csv.flush
        end

        datastream_file2 = get_file_from_source(obj, 1)
        unless datastream_file2.nil?
          md52 = Digest::MD5.file datastream_file2.path
          verification2 = md52.hexdigest
          csv << [obj.id, obj.legacy_pid, 'transfer binary', verification2]
          csv.flush
        end
      end
      puts "Solrizer task complete."
    end

    desc 'verify objs'
    task verify_generics: :environment do
      csv = CSV.open("verify.csv", "w")

      CSV.foreach(ENV['INDEX_LIST']) do |row|
        pid = row[0]
        obj = ActiveFedora::Base.where('legacy_pid_tesim: "' + pid + '"')
        datastream_file = get_file_from_source(obj.first, 0)
        verification = ""
        verification = "object integrity issue" if obj.length != 1
        md5 = Digest::MD5.file datastream_file.path
        verification = md5.hexdigest if obj.length == 1
        csv << [obj.first.id, obj.first.legacy_pid, 'generic', verification]
      end
    end

    desc 'verify objs'
    task verify_rcr: :environment do
      csv = CSV.open("verify.csv", "w")

      CSV.foreach(ENV['INDEX_LIST']) do |row|
        pid = row[0]
        obj = ActiveFedora::Base.where('legacy_pid_tesim: "' + pid + '"')
        datastream_file = get_file_from_source(obj.first, 0)
        verification = ""
        verification = "object integrity issue" if obj.length != 1
        md5 = Digest::MD5.file datastream_file.path
        verification = md5.hexdigest if obj.length == 1
        csv << [obj.first.id, obj.first.legacy_pid, 'rcr', verification]
      end
    end

    desc 'verify objs'
    task verify_voting: :environment do
      csv = CSV.open("verify.csv", "w")

      CSV.foreach(ENV['INDEX_LIST']) do |row|
        pid = row[0]
        obj = ActiveFedora::Base.where('legacy_pid_tesim: "' + pid + '"')
        datastream_file = get_file_from_source(obj.first, 0)
        verification = ""
        verification = "object integrity issue" if obj.length != 1
        md5 = Digest::MD5.file datastream_file.path
        verification = md5.hexdigest if obj.length == 1
        csv << [obj.first.id, obj.first.legacy_pid, 'voting', verification]
      end
    end
    # rubocop:disable Style/IfInsideElse
    desc 'verify objs'
    task verify_images: :environment do
      csv = CSV.open("verify.csv", "w")

      CSV.foreach(ENV['INDEX_LIST']) do |row|
        pid = row[0]
        obj = ActiveFedora::Base.where('legacy_pid_tesim: "' + pid + '"')
        datastream_file = get_file_from_source(obj.first, 0)
        verification = ""
        verification = "object integrity issue" if obj.length != 1
        md5 = Digest::MD5.file datastream_file.path unless datastream_file.nil?
        if datastream_file.nil?
          verification = "garbage"
        else
          verification = md5.hexdigest if obj.length == 1
        end
        next if obj.first.nil?
        csv << [obj.first.id, obj.first.legacy_pid, 'images', verification]
      end
    end
    desc 'verify objs'
    task verify_teis: :environment do
      csv = CSV.open("verify.csv", "w")

      CSV.foreach(ENV['INDEX_LIST']) do |row|
        pid = row[0]
        obj = ActiveFedora::Base.where('legacy_pid_tesim: "' + pid + '"')
        datastream_file = get_file_from_source(obj.first, 0)
        verification = ""
        verification = "object integrity issue" if obj.length != 1
        md5 = Digest::MD5.file datastream_file.path unless datastream_file.nil?
        if datastream_file.nil?
          verification = "garbage"
        else
          verification = md5.hexdigest if obj.length == 1
        end
        next if obj.first.nil?
        csv << [obj.first.id, obj.first.legacy_pid, 'images', verification]
      end
    end

    desc 'verify objs'
    task verify_eads: :environment do
      csv = CSV.open("verify.csv", "w")

      CSV.foreach(ENV['INDEX_LIST']) do |row|
        pid = row[0]
        obj = ActiveFedora::Base.where('legacy_pid_tesim: "' + pid + '"')
        datastream_file = get_file_from_source(obj.first, 0)
        verification = ""
        verification = "object integrity issue" if obj.length != 1
        md5 = Digest::MD5.file datastream_file.path unless datastream_file.nil?
        if datastream_file.nil?
          verification = "garbage"
        else
          verification = md5.hexdigest if obj.length == 1
        end
        next if obj.first.nil?
        csv << [obj.first.id, obj.first.legacy_pid, 'eads', verification]
      end
    end
  end
end
