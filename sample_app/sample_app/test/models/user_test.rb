require 'test_helper'
require 'faker'

class UserTest < ActiveSupport::TestCase

  def setup
    # Clear used email values in faker
    Faker::Internet.unique.clear
    # Set seed
    Faker::Config.random = Random.new(42)
    
    # Generate 50 fake users
    @users = [];
    (1..50).each do |i|
      password = Faker::String.random(6..12) # Random UTF-8 string 
      @users << User.new({ name: Faker::Name.name, email: Faker::Internet.unique.email,
                           password: password, password_confirmation: password })
    end

    password = Faker::String.random(6..12)
    @user = User.new({ name: Faker::Name.name, email: Faker::Internet.unique.email,
                       password: password, password_confirmation: password })
  end

  test "should be valid" do
    @users.each do |user|
      assert user.valid?, user.errors.full_messages
    end
  end

  test "email should be invalid" do
    invalid_addresses = %w[user@example,com user_at_foo.org user.name@example.
                           foo@bar_baz.com foo@bar+baz.com]
    invalid_addresses.each do |invalid_address|
      @user.email = invalid_address
      assert_not @user.valid?, "#{invalid_address.inspect} should be invalid"
    end
  end

  test "email address should be unique" do
    duplicate_user = @user.dup
    @user.save
    duplicate_user.email.upcase!
    assert_not duplicate_user.valid?, "#{duplicate_user.email.inspect} should be invalid"
  end

  test "email addresses should be saved as lower-case" do
    mixed_case_email = "Foo@ExAMPle.CoM"
    @user.email = mixed_case_email
    @user.save
    assert_equal mixed_case_email.downcase, @user.reload.email
  end

  test "short password should be invalid" do
    password = Faker::String.random(2..5)
    @user.password = password
    @user.password_confirmation = password
    assert_not @user.valid?, "#{password.inspect} should be less than 6 char"
  end

end
