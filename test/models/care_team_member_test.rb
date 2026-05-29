# == Schema Information
#
# Table name: care_team_members
#
#  id           :bigint           not null, primary key
#  contact_name :string
#  email        :string
#  name         :string
#  notes        :text
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
  # test "the truth" do
  #   assert true
  # end
end
