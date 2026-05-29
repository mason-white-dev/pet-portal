# == Schema Information
#
# Table name: care_team_members
#
#  id           :bigint           not null, primary key
#  email        :string
#  name         :string
#  notes        :text
#  organization :string
#  phone        :string
#  role         :string
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  pet_id       :bigint           not null
#
# Indexes
#
#  index_care_team_members_on_pet_id  (pet_id)
#
# Foreign Keys
#
#  fk_rails_...  (pet_id => pets.id)
#
require "test_helper"

class CareTeamMemberTest < ActiveSupport::TestCase
  setup do
    # The valid member from the fixtures (belongs to pets(:one)).
    @care_team_member = care_team_members(:one)
  end

  test "should be valid with all required attributes" do
    assert @care_team_member.valid?
  end

  test "should require a name" do
    @care_team_member.name = nil
    assert_not @care_team_member.valid?
    assert_includes @care_team_member.errors[:name], "can't be blank"
  end

  test "should require a role" do
    @care_team_member.role = nil
    assert_not @care_team_member.valid?
    assert_includes @care_team_member.errors[:role], "can't be blank"
  end

  test "should require a pet association" do
    @care_team_member.pet = nil
    assert_not @care_team_member.valid?
    assert_includes @care_team_member.errors[:pet], "must exist"
  end

  # email is optional, but must look like an email when present.
  test "should allow a blank email" do
    @care_team_member.email = ""
    assert @care_team_member.valid?
  end

  test "should reject a malformed email" do
    @care_team_member.email = "not-an-email"
    assert_not @care_team_member.valid?
    assert_includes @care_team_member.errors[:email], "is invalid"
  end

  test "should accept a well-formed email" do
    @care_team_member.email = "vet@example.com"
    assert @care_team_member.valid?
  end

  # String-backed enum: the value stored in the DB is the literal string
  # (e.g. "emergency_vet"), not an integer, while the helpers still work.
  test "stores the role as its literal string value" do
    @care_team_member.update!(role: :emergency_vet)
    assert_equal "emergency_vet", @care_team_member.reload.role
    assert @care_team_member.emergency_vet?
  end

  test "rejects an unknown role" do
    assert_raises(ArgumentError) { @care_team_member.role = "astronaut" }
  end

  test "role_label humanizes the stored role" do
    assert_equal "Primary Vet", care_team_members(:one).role_label
    @care_team_member.role = :emergency_vet
    assert_equal "Emergency Vet", @care_team_member.role_label
  end

  # `ordered` sorts vets first (enum declaration order), then by name within a
  # role — a deterministic, sensible display order for the profile.
  test "ordered lists vets first, then by name within a role" do
    pet = pets(:one)
    pet.care_team_members.destroy_all
    walker = pet.care_team_members.create!(role: :walker, name: "Zoom Walks")
    vet_b  = pet.care_team_members.create!(role: :primary_vet, name: "Banfield")
    vet_a  = pet.care_team_members.create!(role: :primary_vet, name: "Allcare")
    groomer = pet.care_team_members.create!(role: :groomer, name: "Sudsy")

    assert_equal [ vet_a, vet_b, groomer, walker ], pet.care_team_members.ordered.to_a
  end

  # Pet has_many :care_team_members, dependent: :destroy — removing a pet should
  # take its care team with it (no orphaned rows).
  test "is destroyed along with its pet" do
    pet = @care_team_member.pet
    assert_difference("CareTeamMember.count", -1) do
      pet.destroy
    end
  end
end
