require 'test_helper'

class AuthenticationControllerTest < ActionDispatch::IntegrationTest
  test "should get login" do
    get authentication_login_url
    assert_response :success
  end

  test "should get logout" do
    get authentication_logout_url
    assert_response :success
  end

  test "should get signup" do
    get authentication_signup_url
    assert_response :success
  end

end
