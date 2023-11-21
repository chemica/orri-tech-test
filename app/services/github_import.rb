require 'octokit'

# Wraps the Github API gem
class GithubImport
  def initialize(client = nil)
    @client = client || Octokit::Client.new(access_token: ENV.fetch('GITHUB_TOKEN', nil))
  end

  def update_user(user)
    repos = update_user_repositories(user)
    delete_user_languages(user)
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
    repos.each do |repo|
      languages = @client.languages("#{user.name}/#{repo['name']}")

      languages.each do |language_name, bytes|
        language = Language.find_or_create_by(name: language_name)
        language_user = LanguageUser.find_or_create_by(language:, user:)
        language_user.update(bytes: language_user.bytes + bytes)
      end
    end
  end

  def update_user_stars(user, repos)
    stars = repos.map(&:stars).sum
    user.update(stars:)
  end

  def delete_user_languages(user)
    user.languages_users.delete_all
  end
end
