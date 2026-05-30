module PetsHelper
  # Single source of truth for which FontAwesome glyph represents each pet
  # identity field. The same icons appear next to a field's label in BOTH the
  # Identity card (display) and the pet form (inputs); defining the mapping once
  # here keeps the two in sync — change the icon in one place and both follow.
  PET_FIELD_ICONS = {
    name:          "fa-tag",
    species:       "fa-paw",
    breed:         "fa-dog",
    sex:           "fa-venus-mars",
    date_of_birth: "fa-cake-candles",
    microchip:     "fa-microchip",
    neutered:      "fa-scissors",
    notes:         "fa-note-sticky"
  }.freeze

  # Renders the coral accent icon for a pet field, e.g. pet_field_icon(:species).
  # Pairs with a `.field-label` to form the "🐾 Species" label used across the
  # Identity card and the form. fetch raises on an unknown field, so a typo fails
  # loudly in dev rather than silently rendering no icon.
  def pet_field_icon(field)
    tag.i class: "fa-solid #{PET_FIELD_ICONS.fetch(field)} text-accent me-1"
  end

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
