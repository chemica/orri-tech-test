# User model class
class User < ApplicationRecord
  has_many :languages_users, dependent: :destroy, class_name: 'LanguageUser'
  has_many :languages, through: :languages_users
  has_many :repositories, dependent: :destroy

  validates :name, presence: true, uniqueness: true

  WEIGHTS = {
    star_count: 15,
    repository_count: 20,
    ruby_count: 30,
    python_count: 10,
    golang_count: -10,
    typescript_count: -15
  }.freeze

  LANG = {
    ruby: 'Ruby',
    python: 'Python',
    golang: 'Go',
    typescript: 'TypeScript'
  }.freeze

  def weight
    star_weight +
      repository_weight +
      ruby_weight +
      python_weight +
      golang_weight +
      typescript_weight
  end

  private

  def star_weight
    stars * self.WEIGHTS[:star_count]
  end

  def repository_weight
    repositories.count * self.WEIGHTS[:repository_count]
  end

  def ruby_weight
    languages.where(name: self.LANG['ruby']).count * self.WEIGHTS[:ruby_count]
  end

  def python_weight
    languages.where(name: self.LANG['python']).count * self.WEIGHTS[:python_count]
  end

  def golang_weight
    languages.where(name: self.LANG['golang']).count * self.WEIGHTS[:golang_count]
  end

  def typescript_weight
    languages.where(name: self.LANG['typescript']).count * self.WEIGHTS[:typescript_count]
  end
end
