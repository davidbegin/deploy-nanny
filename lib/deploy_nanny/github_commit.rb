class GithubCommit

  attr_accessor :application, :branch

  def initialize(application, branch, github_account)
    @github_account = github_account
    @application    = application
    @branch         = branch
  end

  def sha
    @sha.nil? ? '       ' : @sha
  end

  def fetch_sha
    @sha = `git ls-remote git@github.com:#{github_account}/#{@application}.git | grep "refs/heads/#{@branch}"`[0...7]
  end

  private

  attr_reader :github_account

end
