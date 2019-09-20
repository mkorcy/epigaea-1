# Defines a new sequence
FactoryGirl.define do
  sequence :object_id do |n|
    "object_id_#{n}"
  end
end
