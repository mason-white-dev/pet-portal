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
class Pet < ApplicationRecord
  belongs_to :user

  # String-backed enums: each value is stored verbatim as a string in the DB
  # (e.g. "male", "dog"), not as an integer. You still get the helpers like
  # `@pet.male?` and scopes like `Pet.dog`, while the raw column values stay
  # human-readable.
  enum :sex, { male: "male", female: "female" }
  enum :species, { dog: "dog", cat: "cat", other: "other" }

  # Validations
  # Ensures that a pet cannot be saved to the database without a name and species.
  validates :name, presence: true
  validates :species, presence: true
end
