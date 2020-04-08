require 'rake'

desc "chronopolis"
task :chronopolis_export_by_id, [:pid] => [:environment] do |_t, args|
  exporter = Chronopolis::Exporter.new
  pid = args[:pid]
  exporter.perform_export(pid)
end

desc "chronopolis"
task chronopolis: :environment do
  exporter = Chronopolis::Exporter.new
  CSV.foreach("/usr/local/hydra/epigaea/chronopolis.txt", headers: false, header_converters: :symbol, encoding: "ISO8859-1:utf-8") do |row|
    pid = row[0]
    exporter.perform_export(pid)
  end
end
