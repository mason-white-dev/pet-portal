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
class CareTeamMember < ApplicationRecord
  belongs_to :pet

  # `validate: { allow_blank: true }` makes an out-of-range role (e.g. a crafted
  # POST with role="astronaut") a graceful validation failure (422) instead of an
  # ArgumentError at assignment time (500). allow_blank lets the presence
  # validation below own the "missing role" message rather than double-reporting.
  enum :role, {
    primary_vet:   "primary_vet",
    emergency_vet: "emergency_vet",
    groomer:       "groomer",
    sitter:        "sitter",
    walker:        "walker",
    trainer:       "trainer",
    other:         "other"
  }, validate: { allow_blank: true }

  # Presence validation: ensures the user actually selected a role, and returns a
  # more user-friendly error message than the enum validation.
  validates :role, presence: true
  validates :name, presence: true
  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }, allow_blank: true

  # Care team is shown vets-first — the enum is declared in priority order, so
  # in_order_of sorts by that declaration — then alphabetically by name within a
  # role. Passing every role key means no member is ever filtered out.
  scope :ordered, -> { in_order_of(:role, roles.keys).order(:name) }

  # Human-friendly version of the stored role: "primary_vet" -> "Primary Vet".
  def role_label
    role&.titleize
  end
end
