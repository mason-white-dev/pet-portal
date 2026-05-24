require "test_helper"

class DashboardControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    sign_in users(:one)
    get root_url
    assert_response :success
  end

  test "redirects to sign in when not authenticated" do
    get root_url
    assert_redirected_to new_user_session_path
  end
end
