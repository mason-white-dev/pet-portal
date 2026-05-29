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
class CareTeamMember < ApplicationRecord
  belongs_to :pet

  enum :role, {
    primary_vet:   "primary_vet",
    emergency_vet: "emergency_vet",
    groomer:       "groomer",
    sitter:        "sitter",
    walker:        "walker",
    trainer:       "trainer",
    other:         "other"
  }

  validates :name, presence: true
  validates :role, presence: true
  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }, allow_blank: true
end
