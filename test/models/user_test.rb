require 'test_helper'

class UserTest < ActiveSupport::TestCase
   test "the user is valid with only an email" do
     user = users(:valid_only_email)
     assert user.valid?
   end

   test "the user is valid with only a phone number" do
     user = users(:valid_only_phone)
     assert user.valid?
   end

   test "the user is valid with a name and phone number" do
     users(:valid).valid?
   end

   test "the user is invalid with no email or phone number" do
     user = users(:invalid_no_email_or_phone)
     refute user.valid?
     assert user.errors.added? :email, "must have an email or a phone number!"
   end

   test "the user must have a first name" do
     user = users(:invalid_no_first_name)
     refute user.valid?
     assert user.errors.added? :first_name, :blank
   end

   test "the user must have a last name" do
     user = users(:invalid_no_last_name)
     refute user.valid?
     assert user.errors.added? :last_name, :blank
   end

   test "two users cannot have the same email" do
     original_user = users(:valid)
     new_user = User.new(email: original_user.email, first_name: "New", last_name: "User")
     refute new_user.valid?
     assert new_user.errors.added? :email, "has already been taken"
   end
end
