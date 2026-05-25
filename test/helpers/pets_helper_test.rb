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
end
