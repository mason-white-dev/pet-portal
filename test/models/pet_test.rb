# == Schema Information
#
# Table name: pets
#
#  id            :bigint           not null, primary key
#  breed         :string
#  date_of_birth :date
#  microchip     :string
#  name          :string
#  neutered      :boolean
#  notes         :text
#  sex           :string
#  species       :string
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  user_id       :bigint           not null
#
# Indexes
#
#  index_pets_on_user_id  (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#
require "test_helper"

class PetTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
