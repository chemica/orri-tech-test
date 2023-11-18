# model for the languages_users join table
#
class LanguageUser < ApplicationRecord
  belongs_to :language
  belongs_to :user
end
