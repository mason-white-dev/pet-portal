require "test_helper"

class CareTeamMembersControllerTest < ActionDispatch::IntegrationTest
  setup do
    @pet = pets(:one)
    @member = care_team_members(:one)   # belongs to @pet
    # Sign in @pet's owner to clear Devise's authenticate_user! before_action.
    sign_in @pet.user
  end

  # --- Auth boundary ---------------------------------------------------------
  test "redirects to sign in when not authenticated" do
    sign_out @pet.user
    get new_pet_care_team_member_url(@pet)
    assert_redirected_to new_user_session_path
  end

  # --- new / edit open only in the modal -------------------------------------
  # A direct (non-frame) visit is bounced to the profile; a turbo-frame request
  # renders the form into the drawer.
  test "new redirects a direct (non-frame) visit to the pet" do
    get new_pet_care_team_member_url(@pet)
    assert_redirected_to pet_url(@pet)
  end

  test "new renders the form for a turbo-frame request" do
    get new_pet_care_team_member_url(@pet), headers: { "Turbo-Frame" => "drawer" }
    assert_response :success
  end

  test "edit redirects a direct (non-frame) visit to the pet" do
    get edit_pet_care_team_member_url(@pet, @member)
    assert_redirected_to pet_url(@pet)
  end

  test "edit renders the form for a turbo-frame request" do
    get edit_pet_care_team_member_url(@pet, @member), headers: { "Turbo-Frame" => "drawer" }
    assert_response :success
  end

  # --- create ----------------------------------------------------------------
  test "should create a care team member under the pet" do
    assert_difference("CareTeamMember.count") do
      post pet_care_team_members_url(@pet), params: { care_team_member: {
        role: "sitter", name: "Jo Lee", organization: "Pet Nanny Co",
        phone: "503-555-0123", email: "jo@example.com", notes: "Weekends only"
      } }
    end
    assert_redirected_to pet_url(@pet)
    assert_equal @pet, CareTeamMember.last.pet
  end

  test "create responds with a list-refresh stream for a turbo-stream request" do
    post pet_care_team_members_url(@pet),
      params: { care_team_member: { role: "walker", name: "Stride Dog Walking" } },
      as: :turbo_stream
    assert_response :success
    assert_match %r{<turbo-stream action="replace" target="care_team_members_pet_#{@pet.id}"}, @response.body
    assert_includes @response.body, "Stride Dog Walking"
  end

  test "create with invalid params re-renders the form unprocessable" do
    assert_no_difference("CareTeamMember.count") do
      post pet_care_team_members_url(@pet), params: { care_team_member: { role: "groomer", name: "" } }
    end
    assert_response :unprocessable_entity
    # The errored form lands back in the frame...
    assert_includes @response.body, "can&#39;t be blank"
    # ...and the response is frame-only (layout: false), not the whole page.
    assert_no_match(/id="sidebarMenu"/, @response.body)
  end

  # --- update ----------------------------------------------------------------
  test "should update the care team member" do
    patch pet_care_team_member_url(@pet, @member), params: { care_team_member: { name: "New Vet Clinic" } }
    assert_redirected_to pet_url(@pet)
    assert_equal "New Vet Clinic", @member.reload.name
  end

  test "update responds with a list-refresh stream for a turbo-stream request" do
    patch pet_care_team_member_url(@pet, @member),
      params: { care_team_member: { name: "Renamed Clinic" } }, as: :turbo_stream
    assert_response :success
    assert_match %r{<turbo-stream action="replace" target="care_team_members_pet_#{@pet.id}"}, @response.body
    assert_includes @response.body, "Renamed Clinic"
  end

  test "update with invalid params re-renders the form unprocessable" do
    original = @member.name
    patch pet_care_team_member_url(@pet, @member), params: { care_team_member: { name: "" } }
    assert_response :unprocessable_entity
    assert_equal original, @member.reload.name
    assert_includes @response.body, "can&#39;t be blank"
    assert_no_match(/id="sidebarMenu"/, @response.body)
  end

  # --- destroy ---------------------------------------------------------------
  test "should destroy the care team member" do
    assert_difference("CareTeamMember.count", -1) do
      delete pet_care_team_member_url(@pet, @member)
    end
    assert_redirected_to pet_url(@pet)
  end

  test "destroy responds with a list-refresh stream for a turbo-stream request" do
    delete pet_care_team_member_url(@pet, @member), as: :turbo_stream
    assert_response :success
    assert_match %r{<turbo-stream action="replace" target="care_team_members_pet_#{@pet.id}"}, @response.body
  end

  # --- confirm_delete (modal) ------------------------------------------------
  test "confirm_delete renders for a turbo-frame request" do
    get confirm_delete_pet_care_team_member_url(@pet, @member), headers: { "Turbo-Frame" => "drawer" }
    assert_response :success
  end

  test "confirm_delete redirects a direct (non-frame) visit to the pet" do
    get confirm_delete_pet_care_team_member_url(@pet, @member)
    assert_redirected_to pet_url(@pet)
  end

  # --- Ownership scoping -----------------------------------------------------
  # Signed in as pets(:one).user. pets(:two) and care_team_members(:two) belong
  # to a different account, so every nested lookup raises RecordNotFound -> 404.
  test "cannot create a member under another user's pet" do
    assert_no_difference("CareTeamMember.count") do
      post pet_care_team_members_url(pets(:two)), params: { care_team_member: { role: "groomer", name: "Sneaky" } }
    end
    assert_response :not_found
  end

  test "cannot edit another user's member" do
    get edit_pet_care_team_member_url(pets(:two), care_team_members(:two))
    assert_response :not_found
  end

  test "cannot update another user's member" do
    patch pet_care_team_member_url(pets(:two), care_team_members(:two)), params: { care_team_member: { name: "Hijacked" } }
    assert_response :not_found
    assert_not_equal "Hijacked", care_team_members(:two).reload.name
  end

  test "cannot destroy another user's member" do
    assert_no_difference("CareTeamMember.count") do
      delete pet_care_team_member_url(pets(:two), care_team_members(:two))
    end
    assert_response :not_found
  end

  # The member lookup is scoped *through* @pet, so a member that belongs to a
  # different pet is unreachable even via a pet I do own.
  test "cannot reach a member through the wrong pet" do
    get edit_pet_care_team_member_url(@pet, care_team_members(:two))
    assert_response :not_found
  end
end
