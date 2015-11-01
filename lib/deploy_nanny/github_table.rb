require "colorize"

class GithubTable

  def initialize(github_account:, application_branches:)
    @github_commits = []
    application_branches.each do |application, branch|
      @github_commits << GithubCommit.new(application, branch, github_account)
    end

    render
  end

  def match(application, sha)
    @github_commits.each do |gc|
      if gc.application == application && gc.sha == sha
        return true
      end
    end
    false
  end

  def fetch_all
    threads = []
    @github_commits.each do |github_commit|
      threads << Thread.new {github_commit.fetch_sha; render}
    end
    threads.map(&:join)
  end

  def build_rows
    rows = []
    @github_commits.each do |gc|
      rows << [gc.application.yellow, gc.branch.magenta, gc.sha.green]
    end
    rows
  end

  def render
    print_title
    puts Terminal::Table.new(
      :title => "Latest github commits",
      :headings => ['app', 'branch', 'sha'],
      :rows => build_rows
    )
  end

  def print_title
    system "clear"
    assets_path  = File.expand_path('../../assets', File.dirname(__FILE__))
    print File.read(File.join(assets_path, "/ascii_title.txt")).
      colorize(:color => :red, :mode => :bold)
    puts ("-" * 65).light_black; puts
  end
end
