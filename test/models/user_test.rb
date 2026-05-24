# == Schema Information
#
# Table name: users
#
#  id                     :bigint           not null, primary key
#  email                  :string           default(""), not null
#  encrypted_password     :string           default(""), not null
#  first_name             :string
#  last_name              :string
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
  test "is valid with a first name, last name, email, and password" do
    user = User.new(email: "new@example.com", password: "password", first_name: "Pat", last_name: "Lee")
    assert user.valid?
  end

  test "requires a first name" do
    user = User.new(email: "new@example.com", password: "password", last_name: "Lee")
    assert_not user.valid?
    assert_includes user.errors[:first_name], "can't be blank"
  end

  test "requires a last name" do
    user = User.new(email: "new@example.com", password: "password", first_name: "Pat")
    assert_not user.valid?
    assert_includes user.errors[:last_name], "can't be blank"
  end

  test "requires an email" do
    user = User.new(first_name: "Pat", last_name: "Lee", password: "password")
    assert_not user.valid?
    assert_includes user.errors[:email], "can't be blank"
  end

  test "requires a password" do
    user = User.new(first_name: "Pat", last_name: "Lee", email: "new@example.com")
    assert_not user.valid?
    assert_includes user.errors[:password], "can't be blank"
  end

  test "requires a unique email" do
    # `users(:one)` pulls the existing user fixture from test/fixtures/users.yml
    existing_user = users(:one)
    user = User.new(first_name: "Pat", last_name: "Lee", password: "password", email: existing_user.email)
    assert_not user.valid?
    assert_includes user.errors[:email], "has already been taken"
  end
end
