require 'active_fedora'

namespace :tufts do

  desc 'change https to http in the rights_statement attribute of all DL objects'

  task fix_https_rights_statements: :environment do

    if ARGV.size != 2
      puts('example usage: rake tufts:fix_https_rights_statements https_pids.txt')
    else
      # Read the rights_statement vocabulary file into a hash of {id => active}
      terms = {}
      yaml = YAML.load_file('./config/authorities/rights_statements.yml')['terms']
      yaml.each { |e| terms[e['id']] = e['active'] }

      examined = 0
      modified = 0
      unknown = 0
      inactive = 0

      filename = ARGV[1]

      File.readlines(filename).each do |line|
        id = line.strip

        begin
          next unless id.present?

          work = ActiveFedora::Base.find(id)
          rights = work[:rights_statement].first.to_s
          new_rights = rights.strip.sub('https', 'http')

          if rights == new_rights
            msg = id + ': ' + rights + ' is OK'
          else
            work[:rights_statement]=[new_rights]
            work.save!
            modified += 1
            msg = id + ': ' + rights + ' became ' + new_rights
          end

          active = terms[new_rights]

          if active.nil?
            msg += ' BUT IS NOT A KNOWN RIGHTS STATEMENT'
            unknown += 1
          elsif !active
            msg += ' BUT IS NOT AN ACTIVE RIGHTS STATEMENT'
            inactive += 1
          end

          examined += 1
          puts(msg)
        rescue ActiveFedora::ObjectNotFoundError
          puts(id + ': NOT FOUND')
        end
      end

      puts('examined ' + examined.to_s + (modified == 1 ? ' rights statement' : ' rights statements'))
      puts('  ' + modified.to_s + (modified == 1 ? ' was modified' : ' were modified'))
      puts('  ' + unknown.to_s + (unknown == 1 ? ' is unknown' : ' are unknown'))
      puts('  ' + inactive.to_s + (inactive == 1 ? ' is inactive' : ' are inactive'))
    end
  end
end
