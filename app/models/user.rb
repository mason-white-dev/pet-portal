class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable, :recoverable, :rememberable, :validatable

  # Custom Validations
  # Ensures that users cannot sign up or update their profile with blank names.
  # If left blank, Devise will automatically block the form submission and show an error.
  validates :first_name, presence: true
  validates :last_name, presence: true
end
