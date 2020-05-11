# Generated via
#  `rails generate hyrax:work GenericObject`
require 'rails_helper'
include Warden::Test::Helpers

# NOTE: If you generated more than one work, you have to set "js: true"
RSpec.feature 'Create a GenericObject', :clean, js: true do
  context 'a logged in admin user' do
    let(:user) { FactoryGirl.create(:admin) }

    before { login_as user }

    scenario do
      visit '/dashboard'
      click_link "Works"
      click_link "Add new work"
      # If you generate more than one work uncomment these lines
      within('form.new-work-select') do
        select 'Generic Object', from: 'work-type-select-box'
        click_button "Create work"
      end
      expect(page).to have_content "Add New Generic Object"
      # Hyrax::BasicMetadata attributes that we don't want in the form
      expect(page).to have_no_content('Keywords')
      expect(page).to have_no_content('Location')
      click_link "Files"

      execute_script("$('.fileinput-button input:first').css({'opacity':'1', 'display':'block', 'position':'relative'})")
      attach_file('files[]', File.absolute_path(file_fixture('pdf-sample.pdf')))
      sleep(1)
      find('#with_files_submit').click
      click_link "Descriptions"
      # Fill out the form with everything
      fill_in "Title", with: "Title \n with \t condensed   spaces  ", match: :prefer_exact
      find(:xpath, '//option[contains(text(), "nowhere")]').select_option
      fill_in 'Abstract', with: " A short   description    with  \t wonky spaces   "
      fill_in 'Alternate Title', with: 'Alternate Title'
      fill_in 'Bibliographic Citation', with: " bibliographic   citation  \n with     spaces    "
      fill_in 'Contributor', with: 'Contributor'
      fill_in 'Corporate Name', with: 'Corporate Name'
      fill_in 'Created By', with: 'Created By'
      fill_in 'Creator', with: '     Name   with   Spaces   '
      fill_in 'Date Copyrighted', with: 'Date Copyrighted'
      fill_in 'Date Created', with: 'Date Created'
      fill_in 'Depositor', with: 'Depositor'
      fill_in 'Description', with: 'Description'
      fill_in 'Embargo Note', with: 'Embargo Note'
      fill_in 'End Date', with: 'End Date'
      fill_in 'Extent', with: 'Extent'
      fill_in 'Format', with: 'Format'
      fill_in 'Funder', with: 'Funder'
      fill_in 'Genre', with: 'Genre'
      fill_in 'Spatial', with: 'Spatial'
      fill_in 'Held By', with: 'Held By'
      fill_in 'Internal Note', with: 'Internal Note'
      fill_in 'Is Part Of', with: 'Is Part Of'
      fill_in 'Language', with: 'Language'
      fill_in 'Legacy PID', with: 'Legacy PID'
      fill_in 'License', with: 'License'
      fill_in 'Personal Name', with: 'Personal Name'
      fill_in 'Primary Date', with: 'Primary Date'
      fill_in 'Provenance', with: 'Provenance'
      fill_in 'Publisher', with: 'Publisher'
      fill_in 'QR Note', with: 'QR Note'
      fill_in 'Replaces', with: 'Replaces'
      fill_in 'Retention Period', with: 'Retention Period'
      fill_in 'Rights Note', with: 'Rights Note'
      select 'Springer Policy', from: 'Rights'
      expect(page).to have_select('Rights', selected: 'Springer Policy')
      fill_in 'Source', with: 'Source'
      fill_in 'Start Date', with: 'Start Date'
      select 'dca', from: 'Steward'
      expect(page).to have_select('Steward', selected: 'dca')
      fill_in 'Subject', with: 'Subject'
      fill_in 'Table of Contents', with: 'Table of Contents'
      fill_in 'Temporal', with: 'Temporal'
      fill_in 'Tufts License', with: 'Tufts License'
      select 'Text', from: 'Type'
      # Attach a file

      find('#with_files_submit').click
      expect(page).to have_content 'Title with condensed spaces'
      expect(page).to have_content 'nowhere'
      expect(page).to have_content 'A short description with wonky spaces'
      expect(page).to have_content 'Alternate Title'
      expect(page).to have_content 'bibliographic citation with spaces'
      expect(page).to have_content 'Contributor'
      expect(page).to have_content 'Corporate Name'
      expect(page).to have_content 'Created By'
      expect(page).to have_content 'Name with Spaces'
      expect(page).to have_content 'Date Copyrighted'
      expect(page).to have_content 'Date Created'
      expect(page).to have_content 'Depositor'
      expect(page).to have_content 'Description'
      expect(page).to have_content 'Embargo Note'
      expect(page).to have_content 'End Date'
      expect(page).to have_content 'Extent'
      expect(page).to have_content 'Format'
      expect(page).to have_content 'Funder'
      expect(page).to have_content 'Genre'
      expect(page).to have_content 'Spatial'
      expect(page).to have_content 'Held By'
      expect(page).to have_content 'Internal Note'
      expect(page).to have_content 'Is Part Of'
      expect(page).to have_content 'Language'
      expect(page).to have_content 'Legacy PID'
      expect(page).to have_content 'License'
      expect(page).to have_content 'Personal Name'
      expect(page).to have_content 'Primary Date'
      expect(page).to have_content 'Provenance'
      expect(page).to have_content 'Publisher'
      expect(page).to have_content 'QR Note'
      expect(page).to have_content 'Replaces'
      expect(page).to have_content 'Retention Period'
      expect(page).to have_content 'Rights Note'
      expect(page).to have_content 'Springer Policy'
      expect(page).to have_content 'Source'
      expect(page).to have_content 'Steward'
      expect(page).to have_content 'Subject'
      expect(page).to have_content 'Table of Contents'
      expect(page).to have_content 'Temporal'
      expect(page).to have_content 'Text'
    end
  end
end
