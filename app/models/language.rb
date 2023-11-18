# Language model class
class Language < ApplicationRecord
  has_many :users, through: :languages_users
  has_many :languages_users, dependent: :destroy, class_name: 'LanguageUser'

  validates :name, presence: true, uniqueness: true

  def self.find_or_create_by_name(name)
    Language.find_or_create_by(name: name)
  end
end
