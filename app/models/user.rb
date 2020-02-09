class User < ApplicationRecord
  validates :email, uniqueness: true
  validates_format_of :email, with: /@/
  validates :password_digest, presence: true

  # Pass the hard work of password processing off to bcrypt
  has_secure_password

  # Core relationships
  has_many :lists, dependent: :destroy
  has_many :todos, through: :lists
end
