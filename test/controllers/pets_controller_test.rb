require "test_helper"

class PetsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @pet = pets(:one)
    # We must sign in the user who owns this pet to pass the Devise `authenticate_user!` before_action
    sign_in @pet.user
  end

  test "should get index" do
    get pets_url
    assert_response :success
  end

  test "should get new" do
    get new_pet_url
    assert_response :success
  end

  test "should create pet" do
    assert_difference("Pet.count") do
      post pets_url, params: { pet: { breed: @pet.breed, date_of_birth: @pet.date_of_birth, microchip: @pet.microchip, name: @pet.name, neutered: @pet.neutered, notes: @pet.notes, sex: @pet.sex, species: @pet.species } }
    end

    assert_redirected_to pet_url(Pet.last)
  end

  test "should show pet" do
    get pet_url(@pet)
    assert_response :success
  end

  test "should get edit" do
    get edit_pet_url(@pet)
    assert_response :success
  end

  test "should update pet" do
    patch pet_url(@pet), params: { pet: { breed: @pet.breed, date_of_birth: @pet.date_of_birth, microchip: @pet.microchip, name: @pet.name, neutered: @pet.neutered, notes: @pet.notes, sex: @pet.sex, species: @pet.species } }
    assert_redirected_to pet_url(@pet)
  end

  test "should destroy pet" do
    assert_difference("Pet.count", -1) do
      delete pet_url(@pet)
    end

    assert_redirected_to pets_url
  end

  # --- Ownership scoping -----------------------------------------------------
  # Every action looks pets up through current_user.pets, so a pet owned by
  # someone else is unreachable: current_user.pets.find raises RecordNotFound,
  # which Rails renders as a 404. We're signed in as pets(:one).user, while
  # pets(:two) belongs to a different user.

  test "index lists only the current user's pets" do
    get pets_url
    assert_response :success
    assert_includes @response.body, pets(:one).name      # ours (Bella)
    assert_not_includes @response.body, pets(:two).name  # someone else's (Miso)
  end

  test "cannot view another user's pet" do
    get pet_url(pets(:two))
    assert_response :not_found
  end

  test "cannot update another user's pet" do
    patch pet_url(pets(:two)), params: { pet: { name: "Hijacked" } }
    assert_response :not_found
    assert_not_equal "Hijacked", pets(:two).reload.name
  end

  test "cannot destroy another user's pet" do
    assert_no_difference("Pet.count") do
      delete pet_url(pets(:two))
    end
    assert_response :not_found
  end
end
