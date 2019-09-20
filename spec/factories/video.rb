FactoryGirl.define do
  factory :video do
    title [FFaker::Book.title]
    visibility Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC
    displays_in ['nowhere']
    rights_statement ['http://bostonhistory.org/photorequest.html']
  end
end
