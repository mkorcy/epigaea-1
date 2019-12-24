require 'active_fedora'

namespace :tufts do
  desc 'update the steward attribute of DL objects'

  task update_stewards: :environment do
    if ARGV.size != 2
      puts('example usage: rake tufts:update_stewards some_pids.txt')
    else
      updates = {
        'DCA' =>     'dca',
        'Tisch' =>   'tisch',
        'Tisch Library' => 'tisch',
        '' => 'tisch'
      }

      examined = 0
      updated = 0
      not_updated = 0
      not_found = 0

      filename = ARGV[1]

      File.readlines(filename).each do |line|
        id = line.strip
        msg = id + ': '

        begin
          next unless id.present?

          work = ActiveFedora::Base.find(id)
          rights = work[:steward].to_s

          msg += rights

          updated_rights = updates[rights]

          if updated_rights.nil?
            msg += ' DOES NOT HAVE A REPLACEMENT IN THE RAKE TASK'
            not_updated += 1
          else
            work[:steward] = updated_rights
            work.save!
            updated += 1
            msg += ' updated to ' + updated_rights
          end

          examined += 1
        rescue ActiveFedora::ObjectNotFoundError
          not_found += 1
          msg += ' NOT FOUND'
        end

        puts(msg)
      end

      puts('examined ' + examined.to_s + (examined == 1 ? ' steward' : ' stewards'))
      puts('  ' + updated.to_s + (updated == 1 ? ' was updated' : ' were updated'))
      puts('  ' + not_updated.to_s + (not_updated == 1 ? ' was not updated' : ' were not updated'))
      puts('  ' + not_found.to_s + (not_found == 1 ? ' was not found' : ' were not found'))
    end
  end
end
