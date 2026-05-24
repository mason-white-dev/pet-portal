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
  setup do
    # Load the valid pet from the pets.yml fixture
    @valid_pet = pets(:one)
  end

  test "should be valid with all required attributes" do
    assert @valid_pet.valid?
  end

  test "should require a name" do
    @valid_pet.name = nil
    assert_not @valid_pet.valid?
    assert_includes @valid_pet.errors[:name], "can't be blank"
  end

  test "should require a species" do
    @valid_pet.species = nil
    assert_not @valid_pet.valid?
    assert_includes @valid_pet.errors[:species], "can't be blank"
  end

  test "should require a user association" do
    @valid_pet.user = nil
    assert_not @valid_pet.valid?
    assert_includes @valid_pet.errors[:user], "must exist"
  end
end
