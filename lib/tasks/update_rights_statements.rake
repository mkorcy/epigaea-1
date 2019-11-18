require 'active_fedora'

namespace :tufts do
  desc 'update the rights_statement attribute of DL objects'

  task update_rights_statements: :environment do
    if ARGV.size != 2
      puts('example usage: rake tufts:update_rights_statements some_pids.txt')
    else
      updates_hash = {
        'http://dca.tufts.edu/ua/access/rights-creator.html'                => 'http://dca.tufts.edu/research/policies-fees/reproductions-and-use',
        'http://dca.tufts.edu/ua/access/rights-creator.htm'                 => 'http://dca.tufts.edu/research/policies-fees/reproductions-and-use',
        'http://dca.tufts.edu/ua/access/rights-creators.html'               => 'http://dca.tufts.edu/research/policies-fees/reproductions-and-use',
        'http://dca.tufts.edu/ua/access/rights-tufts.html'                  => 'http://dca.tufts.edu/research/policies-fees/reproductions-and-use',

        'http://sites.tufts.edu/dca/research-help/copyright-and-citations/' => 'http://dca.tufts.edu/research/policies-fees/reproductions-and-use',
        'http://sites.tufts.edu/dca/about-us/research-help/reproductions-and-use/' =>
                                                                               'http://dca.tufts.edu/research/policies-fees/reproductions-and-use',
        'http://sites.tufts.edu/dca/about-us/research-help/citations/copyright-and-citations-for-bostonian-society-images/' =>
                                                                               'http://dca.tufts.edu/research/help-with-copyright/copyright-and-citations-for-bostonian-society-images',
        'http://sites.tufts.edu/dca/about-us/research-help/citations/copyright-and-citations-for-material-from-the-edward-r-murrow-collection/' =>
                                                                               'http://dca.tufts.edu/research/help-with-copyright/copyright-and-citations-for-material-from-the-edward-r-murrow-collection',

        'http://creativecommons.org/licenses/by/2.0'                        => 'http://creativecommons.org/licenses/by/2.0/',
        'http://creativecommons.org/licenses/by/4.0/deed.en_US'             => 'http://creativecommons.org/licenses/by/4.0/',

        'http://creativecommons.org/licenses/by/4.0'                        => 'http://creativecommons.org/licenses/by/4.0/',
        'http://www.creativecommons.org/licenses/by/2.0'                    => 'http://creativecommons.org/licenses/by/2.0/',
        'https://creativecommons.org/licenses/by-nc/4.0/'                   => 'http://creativecommons.org/licenses/by-nc/4.0/',

        'http://pubs.acs.org/page/policy/authorchoice_termsofuse.html'      => 'http://rightsstatements.org/page/InC/1.0/',
        'http://www.elsevier.com/about/our-business/policies/sharing'       => 'http://rightsstatements.org/page/InC/1.0/',

        'http://rightsstatements.org/page/1.0/?language=en'                 => 'http://rightsstatements.org/page/1.0/',
        'http://rightsstatements.org/page/CNE/1.0/?language=en'             => 'http://rightsstatements.org/page/CNE/1.0/',
        'http://rightsstatements.org/page/InC/1.0/?language=en'             => 'http://rightsstatements.org/page/InC/1.0/',
        'http://rightsstatements.org/page/InC-EDU/1.0/?language=en'         => 'http://rightsstatements.org/page/InC-EDU/1.0/',
        'http://rightsstatements.org/page/InC-NC/1.0/?language=en'          => 'http://rightsstatements.org/page/InC-NC/1.0/',
        'http://rightsstatements.org/page/InC-RUU/1.0/?language=en'         => 'http://rightsstatements.org/page/InC-RUU/1.0/',
        'http://rightsstatements.org/page/NoC-US/1.0/?language=en'          => 'http://rightsstatements.org/page/NoC-US/1.0/',
        'http://rightsstatements.org/page/UND/1.0/?language=en'             => 'http://rightsstatements.org/page/UND/1.0/',
        'http://rightsstatements.org/page/NKC/1.0/?language=en'             => 'http://rightsstatements.org/page/NKC/1.0/',
        'http://rightsstatements.org/vocab/CNE/1.0/'                        => 'http://rightsstatements.org/page/CNE/1.0/',
        'http://rightsstatements.org/vocab/InC/1.0/'                        => 'http://rightsstatements.org/page/InC/1.0/',
        'http://rightsstatements.org/vocab/InC-EDU/1.0/'                    => 'http://rightsstatements.org/page/InC-EDU/1.0/',
        'http://rightsstatements.org/vocab/InC-NC/1.0/'                     => 'http://rightsstatements.org/page/InC-NC/1.0/',
        'http://rightsstatements.org/vocab/InC-RUU/1.0/'                    => 'http://rightsstatements.org/page/InC-RUU/1.0/',
        'http://rightsstatements.org/vocab/NoC-US/1.0/'                     => 'http://rightsstatements.org/page/NoC-US/1.0/',
        'http://rightsstatements.org/vocab/UND/1.0/'                        => 'http://rightsstatements.org/page/UND/1.0/',
        'http://rightsstatements.org/vocab/NKC/1.0/'                        => 'http://rightsstatements.org/page/NKC/1.0/',

        'http://www.acm.org/publications/policies/copyright_policy'         => 'http://www.acm.org/publications/policies/copyright-policy',
        'http://www.springer.com/authors/journal+authors?SGWID=0-154202-12-467999-0' =>
                                                                               'http://www.springer.com/us/authors-editors/journal-author',
      }

      # Read the rights_statement vocabulary file into a hash of {id => count}
      known_count = 0
      known_hash = {}
      yaml = YAML.load_file('./config/authorities/rights_statements.yml')['terms']
      yaml.each { |e| known_hash[e['id']] = 0 }

      unknown_count = 0
      unknown_hash = {}
      not_found_array = []
      found_count = 0
      updated_count = 0
      updated_hash = {}
      not_updated_count = 0
      not_updated_hash = {}
      exception_array = []

      filename = ARGV[1]

      File.readlines(filename).each do |line|
        id = line.strip
        msg = ''

        begin
          next unless id.present?

          work = ActiveFedora::Base.find(id)
          rights = work[:rights_statement].first.to_s

          msg += rights

          updated_rights = updates_hash[rights]

          if updated_rights.nil?
            # This work was not updated, because there was no replacement in updates_hash.
            msg += ' not updated'
            not_updated_count += 1
            hash_count = not_updated_hash[rights]

            not_updated_hash[rights] = (hash_count.nil? ? 1 : hash_count + 1)

            final_rights = rights
          else
            # Do the update.
            work[:rights_statement] = [updated_rights]
            work.save!

            # This work was updated.
            msg += ' updated to ' + updated_rights
            updated_count += 1
            hash_count = updated_hash[msg]

            updated_hash[msg] = (hash_count.nil? ? 1 : hash_count + 1)

            final_rights = updated_rights
          end

          found_count += 1

          hash_count = known_hash[final_rights]

          if hash_count.nil?
            # This rights statement url is unknown.
            unknown_count += 1
            hash_count = unknown_hash[final_rights]

            unknown_hash[final_rights] = (hash_count.nil? ? 1 : hash_count + 1)
          else
            # This rights statement url is known.
            known_count += 1
            known_hash[final_rights] = hash_count + 1
          end
        rescue ActiveFedora::ObjectNotFoundError
          # This work was not found.
          not_found_array << id
          msg += 'not found'
        rescue StandardError => ex
          # Something went wrong.  For example, "ActiveFedora::RecordInvalid: Validation failed: Embargo release date Must be a future date".
          exception_msg = ' ' + ex.class.name + ' ' + ex.message
          exception_array << id + exception_msg
          msg += ' caused the exception' + exception_msg
          found_count += 1
        end

        puts(id + ': ' + msg)
      end

      puts

      # How many works were not found?
      not_found_count = not_found_array.size

      if not_found_count > 0
        puts(not_found_count.to_s + (not_found_count == 1 ? ' work was' : ' works were') + ' not found:')

        not_found_array.each do |not_found_id|
          puts('  ' + not_found_id)
        end
      end

      # How many works were found?
      if found_count > 0
        puts(found_count.to_s + (found_count == 1 ? ' work was' : ' works were') + ' found.')
      end

      # How many works caused exceptions?
      exception_count = exception_array.size

      if exception_count > 0
        puts('  ' + exception_count.to_s + (exception_count == 1 ? ' work caused an exception' : ' works caused exceptions') + ':')

        exception_array.each do |exception_msg|
          puts('    ' + exception_msg)
        end
      end

      # How many works were updated?
      if updated_count > 0
        puts('  ' + updated_count.to_s + (updated_count == 1 ? ' work was' : ' works were') + ' updated:')

        updated_hash.each do |message, count|
          puts('    ' + message + ': ' + count.to_s)
        end
      end

      # How many works were not updated?
      if not_updated_count > 0
        puts('  ' + not_updated_count.to_s + (not_updated_count == 1 ? ' work was' : ' works were') + ' not updated:')

        not_updated_hash.each do |rights, count|
          puts('    ' + rights + ': ' + count.to_s)
        end
      end

      puts

      # How many rights statements were known?
      if known_count > 0
        puts('  ' + known_count.to_s + (known_count == 1 ? ' work was' : ' works were') + ' known:')

        known_hash.each do |rights, count|
          if count > 0
            puts('    ' + rights + ': ' + count.to_s)
          end
        end
      end

      # How many rights statements were unknown?
      if unknown_count > 0
        puts('  ' + unknown_count.to_s + (unknown_count == 1 ? ' work was' : ' works were') + ' unknown:')

        unknown_hash.each do |rights, count|
          puts('    ' + rights + ': ' + count.to_s)
        end
      end
    end
  end
end
