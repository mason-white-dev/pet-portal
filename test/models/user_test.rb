# == Schema Information
#
# Table name: users
#
#  id                     :bigint           not null, primary key
#  email                  :string           default(""), not null
#  encrypted_password     :string           default(""), not null
#  remember_created_at    :datetime
#  reset_password_sent_at :datetime
#  reset_password_token   :string
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#
# Indexes
#
#  index_users_on_email                 (email) UNIQUE
#  index_users_on_reset_password_token  (reset_password_token) UNIQUE
#
require "test_helper"

class UserTest < ActiveSupport::TestCase
  setup do
    # Load a fully valid, persisted user from the fixtures
    @valid_user = users(:one)
  end

  test "is valid with all required attributes" do
    assert @valid_user.valid?
  end

  test "requires an email" do
    @valid_user.email = nil
    assert_not @valid_user.valid?
    assert_includes @valid_user.errors[:email], "can't be blank"
  end

  test "requires a password on creation" do
    # Devise only validates password presence on *creation*, not on updates.
    # Therefore, we still need to build a new record for this specific test.
    new_user = User.new(first_name: "Pat", last_name: "Lee", email: "new@example.com")
    assert_not new_user.valid?
    assert_includes new_user.errors[:password], "can't be blank"
  end

  test "requires a unique email" do
    # Attempt to create a new user using the email of our existing @valid_user fixture
    new_user = User.new(first_name: "Pat", last_name: "Lee", password: "password", email: @valid_user.email)
    assert_not new_user.valid?
    assert_includes new_user.errors[:email], "has already been taken"
  end
end
