module PetsHelper
  # Compact one-line descriptor for a pet — e.g. "Mini Australian Shepherd • Dog • 4 yr".
  # Built from whatever's present (breed, species, short age). Shown in the
  # profile header and the About photo card so the logic lives in one place.
  def pet_subtitle(pet)
    parts = [ pet.breed.presence, pet.species&.humanize.presence ].compact

    if pet.date_of_birth.present?
      age = time_ago_in_words(pet.date_of_birth)
              .gsub("about ", "").gsub(" years", " yr").gsub(" year", " yr")
      parts << age
    end

    parts.join(" • ")
  end
end
