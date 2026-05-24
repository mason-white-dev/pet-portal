json.extract! pet, :id, :user_id, :name, :species, :sex, :breed, :date_of_birth, :microchip, :neutered, :notes, :created_at, :updated_at
json.url pet_url(pet, format: :json)
