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

  test "should accept a valid avatar image upload" do
    @valid_pet.avatar_image.attach(
      io: StringIO.new("fake image data"),
      filename: "avatar.jpg",
      content_type: "image/jpeg"
    )
    assert @valid_pet.valid?
  end

  test "should reject avatar images with invalid content types" do
    @valid_pet.avatar_image.attach(
      io: StringIO.new("fake text data"),
      filename: "document.txt",
      content_type: "text/plain"
    )
    assert_not @valid_pet.valid?
    assert_includes @valid_pet.errors[:avatar_image], "must be a valid image format (JPEG, PNG, GIF, WEBP)"
  end

  test "should reject avatar images larger than 5MB" do
    # Generate a 6MB string in memory to simulate a massive file upload
    large_file = "a" * 6.megabytes

    @valid_pet.avatar_image.attach(
      io: StringIO.new(large_file),
      filename: "large_avatar.jpg",
      content_type: "image/jpeg"
    )

    assert_not @valid_pet.valid?
    assert_includes @valid_pet.errors[:avatar_image], "is too big (must be under 5MB)"
  end
end
