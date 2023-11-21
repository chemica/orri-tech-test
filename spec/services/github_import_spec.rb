require 'rails_helper'

RSpec.describe GithubImport do
  let(:client) { double('Octokit::Client') }
  let(:user) { User.create(name: 'testuser') }
  subject { GithubImport.new client }

  describe '#update_user' do
    let(:rubyrepo) { double('Octokit::Repository', name: 'rubyrepo', language: 'Ruby', stargazers_count: 13) }
    let(:pythonrepo) { double('Octokit::Repository', name: 'pythonrepo', language: 'Python', stargazers_count: 7) }
    let(:csharprepo) { double('Octokit::Repository', name: 'csharprepo', language: 'CSharp', stargazers_count: 3) }
    let(:rust_repository) { Repository.new(name: 'rust_repository', language: Language.new(name: 'Rust'), stars: 5) }

    before do
      allow(client).to receive(:languages).with("#{user.name}/rubyrepo").and_return(Ruby: 10_012)
      allow(client).to receive(:languages).with("#{user.name}/pythonrepo").and_return(Python: 50)
      allow(client).to receive(:languages).with("#{user.name}/csharprepo").and_return(CSharp: 7012)
    end

    it 'calls Octokit client to get repositories' do
      expect(client).to receive(:repositories).with(user.name).once.and_return [rubyrepo]
      subject.update_user user
    end

    it 'adds repositories to user' do
      allow(client).to receive(:repositories).with(user.name).and_return [rubyrepo, pythonrepo]
      subject.update_user user

      expect(user.repositories.count).to eq 2
    end

    it 'fills repositories with data' do
      allow(client).to receive(:repositories).with(user.name).and_return([rubyrepo])
      subject.update_user user

      expect(user.repositories.first.name).to eq(rubyrepo.name)
      expect(user.repositories.first.language.name).to eq(rubyrepo.language)
      expect(user.repositories.first.stars).to eq(rubyrepo.stargazers_count)
    end

    it 'adds languages to user' do
      allow(client).to receive(:repositories).with(user.name).and_return([rubyrepo, pythonrepo])
      subject.update_user user

      expect(user.languages.count).to eq 2
      expect(Language.count).to eq 2
    end

    it 'removes stale repositories' do
      allow(client).to receive(:repositories).with(user.name).and_return([rubyrepo, pythonrepo])
      user.repositories << rust_repository
      user.save

      subject.update_user(user)
      user.reload

      expect(user.repositories.count).to eq 2
      expect(user.repositories.map(&:name)).to include('rubyrepo')
      expect(user.repositories.map(&:name)).to include('pythonrepo')
      expect(user.repositories.map(&:name)).not_to include('rust_repository')
      expect(Repository.count).to eq 2
    end

    it 'removes stale languages' do
      allow(client).to receive(:repositories).with(user.name).and_return([rubyrepo, pythonrepo])
      user.languages << Language.find_or_create_by(name: 'rust')
      user.save
      subject.update_user user
      user.reload

      expect(user.languages.count).to eq 2
      expect(user.languages_users.count).to eq 2
      expect(user.languages.map(&:name)).not_to include('rust')
      expect(Language.count).to eq 3
    end

    it 'updates user stars' do
      allow(client).to receive(:repositories).with(user.name).and_return([csharprepo, pythonrepo])
      subject.update_user user
      expect(user.stars).to eq 10
    end
  end
end
