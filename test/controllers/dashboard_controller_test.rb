require "test_helper"

class DashboardControllerTest < ActionDispatch::IntegrationTest
  # This acts as a "smoke test". It doesn't test the HTML content of the page,
  # it just ensures that when an authenticated user requests the dashboard,
  # the controller, database, and view all compile and execute without crashing (returning a 200 OK).
  test "should get index" do
    sign_in users(:one)
    get root_url
    assert_response :success
  end

  # Ensures that Devise's `authenticate_user!` before_action is properly
  # protecting the dashboard from unauthenticated visitors.
  test "redirects to sign in when not authenticated" do
    get root_url
    assert_redirected_to new_user_session_path
  end
end
