class Language < ApplicationRecord
  has_many :users, through: :languages_users
  has_many :languages_users, dependent: :destroy
end
