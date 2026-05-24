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

  # Enums map string values (like 'male' or 'dog') to integers in the database.
  # This automatically gives you methods like `@pet.male?` or `Pet.dog` (to get all dogs).
  enum :sex, { male: "male", female: "female" }
  enum :species, { dog: "dog", cat: "cat", other: "other" }

  # Validations
  # Ensures that a pet cannot be saved to the database without a name and species.
  validates :name, presence: true
  validates :species, presence: true
end
