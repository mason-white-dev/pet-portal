require "test_helper"

class PetsHelperTest < ActionView::TestCase
  test "joins breed, species, and a short age with bullets" do
    pet = Pet.new(breed: "Mini Aussie", species: "dog", date_of_birth: 4.years.ago.to_date)
    subtitle = pet_subtitle(pet)

    assert_includes subtitle, "Mini Aussie"
    assert_includes subtitle, "Dog"   # species humanized
    assert_match(/\byr\b/, subtitle)  # age shortened from "years"
    assert_includes subtitle, "•"     # parts joined with bullets
  end

  test "omits parts that aren't present" do
    # Only species set: no breed, no birthday -> just the species, no stray bullets.
    assert_equal "Cat", pet_subtitle(Pet.new(species: "cat"))
  end

  test "is blank when nothing is present" do
    assert_equal "", pet_subtitle(Pet.new)
  end

  test "pet_field_icon renders the mapped glyph as a coral accent <i>" do
    html = pet_field_icon(:species)

    assert_includes html, "fa-paw"        # the glyph mapped to :species
    assert_includes html, "fa-solid"      # FontAwesome style
    assert_includes html, "text-accent"   # brand coral
    assert_match(/\A<i /, html)           # rendered as an <i> tag
  end

  test "pet_field_icon raises on an unknown field" do
    # fetch fails loudly so a typo'd field name surfaces in dev rather than
    # silently rendering no icon.
    assert_raises(KeyError) { pet_field_icon(:not_a_field) }
  end
end
