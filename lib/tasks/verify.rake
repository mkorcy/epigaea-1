require 'digest'

namespace :tufts do
  def get_file_from_source(source, index)
    return nil if source.ordered_file_sets[index].nil?

    target_file = source.ordered_file_sets[index].label
    puts "#{source.id} target #{index}: " + target_file
    voting_record = File.new target_file, 'wb'
    voting_record.write source.ordered_file_sets[index].original_file.content
    voting_record.flush
    voting_record.close
    File.new target_file
  end

  def delete_dl_file(source, index)
    target_file = source.file_sets[index].label
    FileUtils.rm(target_file)
  end

  namespace :fedora do
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
    task verify_images: :environment do
      csv = CSV.open("verify.csv", "w")

      CSV.foreach(ENV['INDEX_LIST']) do |row|
        pid = row[0]
        obj = ActiveFedora::Base.where('legacy_pid_tesim: "' + pid + '"')
        datastream_file = get_file_from_source(obj, 0)
        md5 = Digest::MD5.file datastream_file.path
        csv << [obj.pid, v, md5.hexdigest]
      end
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
        delete_dl_file(obj.first, 0)
      end
    end
  end
end
