# User model class
class User < ApplicationRecord
  has_many :languages_users, dependent: :destroy, class_name: 'LanguageUser'
  has_many :languages, through: :languages_users
  has_many :repositories, dependent: :destroy

  validates :name, presence: true, uniqueness: true
end
