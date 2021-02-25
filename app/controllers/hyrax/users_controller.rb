# @file
# # Patched for https://github.com/samvera/hyrax/pull/4660
require_dependency Hyrax::Engine.root.join('app', 'controllers', 'hyrax', 'users_controller').to_s

module Hyrax
  class UsersController
     def find_user
       @user = ::User.from_url_component(params[:id])
       redirect_to root_path, alert: "User does not exist" unless @user
     end
  end
end
