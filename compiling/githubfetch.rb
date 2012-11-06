require "github_api"
require "date"

class GithubFetch
  def self.get_date_for_repo(user, repos)
    repo = Github::Repos.new :user => user
    commits = repo.commits.all user, repos
    latest_commit = commits.first
    date = latest_commit.commit.author.date
    DateTime.parse(date)
  end
end
