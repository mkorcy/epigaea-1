require 'rails_helper'
include Warden::Test::Helpers

RSpec.feature 'Add a work to a collection', :clean, js: true do
  context 'as logged in admin user' do
    let(:admin) { FactoryGirl.create(:admin) }
    let(:work) { FactoryGirl.actor_create(:image, user: admin, displays_in: ['dl']) }
    let!(:collection) { FactoryGirl.create(:collection_lw) }
    let(:title) { FFaker::Book.title }
    let(:ead_id) { 'fake_ead_id' }

    before { login_as admin }

    scenario do
      # collection
      visit '/dashboard'
      click_link "Collections"
      #      interactive_debug_session(user)
      sleep(2)
      click_link "New Collection"

      # EAD is a form entry field when you create a new Collection
      fill_in 'Title', with: title
      fill_in 'EAD', with: ead_id
      click_button "Save"
      click_link "Cancel"
      visit("dashboard/my/collections")
      expect(work.member_of_collections).to be_empty
      visit("/concern/images/#{work.id}/edit#relationships")
      # interactive_debug_session(admin)
      expect(page).to have_content("This work is currently in these collections")
      find('div#s2id_image_member_of_collection_ids').click
      fill_in('s2id_autogen2_search', with: :title)
      sleep(3)
      # .select(collection.title.first)
      # find('input#with_files_submit').click
      find('a[data-behavior="add-relationship"]', match: :first).trigger('click')
      expect(page).to have_content :title
      work.reload
      # expect(work.member_of_collections.first.id).to eq(collection.id)
    end
  end
end
