# User model class
class User < ApplicationRecord
  has_many :languages_users, dependent: :destroy, class_name: 'LanguageUser'
  has_many :languages, through: :languages_users
  has_many :repositories, dependent: :destroy
  has_many :import_slots, dependent: :destroy

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

  def self.weighted_users(limit)
    User.includes(:languages_users, :languages, :repositories)
        .order(created_at: :desc)
        .limit(limit) # More than this will cause the scheduling constraints to fail
        .sort_by(&:weight)
  end

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
    stars * User::WEIGHTS[:star_count]
  end

  def repository_weight
    repositories.count * User::WEIGHTS[:repository_count]
  end

  def ruby_weight
    languages.where(name: User::LANG['ruby']).count * User::WEIGHTS[:ruby_count]
  end

  def python_weight
    languages.where(name: User::LANG['python']).count * User::WEIGHTS[:python_count]
  end

  def golang_weight
    languages.where(name: User::LANG['golang']).count * User::WEIGHTS[:golang_count]
  end

  def typescript_weight
    languages.where(name: User::LANG['typescript']).count * User::WEIGHTS[:typescript_count]
  end
end
