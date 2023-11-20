require 'octokit'

# Wraps the Github API gem
class GithubImport
  def initialize(client = nil)
    @client = client || Octokit::Client.new(access_token: ENV.fetch('GITHUB_TOKEN', nil))
  end

  def update_user(user)
    repos = update_user_repositories(user)
    update_user_languages(user, repos)
    update_user_stars(user, repos)
  end

  private

  def update_user_repositories(user)
    repos = @client.repositories(user.name).map do |repo|
      Repository.find_or_create_by(
        name: repo.name,
        language: Language.find_or_create_by(name: repo.language || 'undefined'),
        stars: repo.stargazers_count,
        user:
      )
    end
    user.repositories.where(id: user.repository_ids - repos.map(&:id)).delete_all
    repos
  end

  def update_user_languages(user, repos)
    languages = repos.map(&:language).uniq.compact
    languages.each do |language|
      user.languages << language
    end
    stale_language_ids = user.language_ids - languages.map(&:id)
    user.languages_users.where(language_id: stale_language_ids).delete_all
  end

  def update_user_stars(user, repos)
    stars = repos.map(&:stars).sum
    user.update(stars:)
  end
end
