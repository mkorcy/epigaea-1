FactoryGirl.define do
  factory :ead do
    title ['Test']
    visibility Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC
  end
end
