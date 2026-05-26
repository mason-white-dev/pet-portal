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

  # Guards the app's auth boundary: an unauthenticated visitor to the pets roster
  # (now the root path) is bounced to sign in by Devise's authenticate_user!
  # before_action. Re-added here after the dashboard — which used to hold this
  # test — was removed.
  test "redirects to sign in when not authenticated" do
    sign_out @pet.user
    get pets_url
    assert_redirected_to new_user_session_path
  end

  # `new` and `edit` are only meant to open in the modal (a turbo-frame request).
  # A direct visit is bounced to the roster/profile; a frame request renders the form.
  test "new redirects a direct (non-frame) visit to the roster" do
    get new_pet_url
    assert_redirected_to pets_url
  end

  test "new renders the form for a turbo-frame request" do
    get new_pet_url, headers: { "Turbo-Frame" => "drawer" }
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

  test "edit redirects a direct (non-frame) visit to the pet" do
    get edit_pet_url(@pet)
    assert_redirected_to pet_url(@pet)
  end

  test "edit renders the form for a turbo-frame request" do
    get edit_pet_url(@pet), headers: { "Turbo-Frame" => "drawer" }
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

  # --- Avatar upload (end-to-end param path) ---------------------------------
  # Confirms :avatar_image flows through pet_params and attaches via the form.
  # Runs on the :test disk service (see config/environments/test.rb), so nothing
  # touches Cloudinary.

  test "attaches an avatar image when creating a pet" do
    assert_difference("Pet.count") do
      post pets_url, params: { pet: {
        name: "Pixel", species: "cat",
        avatar_image: fixture_file_upload("avatar.png", "image/png")
      } }
    end
    assert Pet.last.avatar_image.attached?
    assert_redirected_to pet_url(Pet.last)
  end

  test "attaches an avatar image when updating a pet" do
    patch pet_url(@pet), params: { pet: {
      avatar_image: fixture_file_upload("avatar.png", "image/png")
    } }
    assert @pet.reload.avatar_image.attached?
    assert_redirected_to pet_url(@pet)
  end

  # --- Modal create / update responses ---------------------------------------
  # The form lives in a turbo-frame, so success and failure take different routes:
  # success returns a stream (create → a full-page "redirect" visit; update → an
  # in-place card refresh), while a validation failure re-renders 422 back into
  # the frame so errors show in the open modal.

  test "create responds with a redirect stream for a turbo-stream request" do
    assert_difference("Pet.count") do
      post pets_url, params: { pet: { name: "Pixel", species: "cat" } }, as: :turbo_stream
    end
    assert_response :success
    assert_match %r{<turbo-stream action="redirect"}, @response.body
    assert_includes @response.body, pet_path(Pet.last)
  end

  test "create with invalid params re-renders the form unprocessable" do
    assert_no_difference("Pet.count") do
      post pets_url, params: { pet: { name: "", species: "" } }
    end
    assert_response :unprocessable_entity
    # The errored form actually lands back in the frame...
    assert_includes @response.body, "can&#39;t be blank"
    # ...and the response is frame-only (layout: false), not the whole page.
    assert_no_match(/id="sidebarMenu"/, @response.body)
  end

  test "update with invalid params re-renders the form unprocessable" do
    original = @pet.name
    patch pet_url(@pet), params: { pet: { name: "" } }
    assert_response :unprocessable_entity
    assert_equal original, @pet.reload.name
    assert_includes @response.body, "can&#39;t be blank"
    assert_no_match(/id="sidebarMenu"/, @response.body)
  end

  test "update responds with a turbo stream that refreshes the identity card" do
    patch pet_url(@pet), params: { pet: { name: "Bella Jr." } }, as: :turbo_stream
    assert_response :success
    assert_includes @response.body, "pet_identity_card_pet_#{@pet.id}"
  end

  # --- Delete confirmation (modal) -------------------------------------------

  test "confirm_delete renders for a turbo-frame request" do
    get confirm_delete_pet_url(@pet), headers: { "Turbo-Frame" => "drawer" }
    assert_response :success
  end

  test "confirm_delete redirects a direct (non-frame) visit to the pet" do
    get confirm_delete_pet_url(@pet)
    assert_redirected_to pet_url(@pet)
  end

  test "cannot reach confirm_delete for another user's pet" do
    get confirm_delete_pet_url(pets(:two))
    assert_response :not_found
  end

  # --- Avatar removal flag ---------------------------------------------------
  # "Remove photo" sets pet[remove_avatar_image] = "1"; a successful update then
  # purges the attached avatar.

  test "removing the avatar purges it on update" do
    @pet.avatar_image.attach(
      io: File.open(Rails.root.join("test/fixtures/files/avatar.png")),
      filename: "avatar.png", content_type: "image/png"
    )
    assert @pet.avatar_image.attached?

    patch pet_url(@pet), params: { pet: {
      name: @pet.name, species: @pet.species, remove_avatar_image: "1"
    } }

    assert_not @pet.reload.avatar_image.attached?
  end
end
