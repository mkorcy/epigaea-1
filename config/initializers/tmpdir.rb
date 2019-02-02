require 'fileutils'

# force the whole app to use its own tmpdir
FileUtils.mkdir_p(Rails.root.join('racktmp'))
ENV['TMPDIR'] = Rails.root.join('racktmp').to_s
ENV['TMP'] = Rails.root.join('racktmp').to_s
