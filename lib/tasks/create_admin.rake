require 'rake'

namespace :tufts do
  desc "Create admin user"
  task create_admin: :environment do
    u = User.create(
      email: 'admin@example.org',
      display_name: 'Admin, Example',
      password: 'password'
    )
    u.add_role('admin')
  end
end
