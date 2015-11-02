require_relative "deployer"
require 'spinning_cursor'

module DeployNanny
  class Base
    def initialize(github_account:, deploy_instructions:)
      @github_account      = github_account
      @deploy_instructions = deploy_instructions
      @rows                = []
      @updates             = {}
    end

    def babysit
      display_github_shas!
      display_deployed_shas!
      deploy_to_outdated_envs!
    end

    private

    attr_reader :github_account, :deploy_instructions

    def display_deployed_shas!
      puts "\n"
      SpinningCursor.run do
        banner "Pulling SHA's from servers".yellow
        type :spinner
        action { fetch_and_display_shas! }
        message "\n"
      end
    end

    def fetch_and_display_shas!
      apps.each do |app, app_info|
        app_info["envs"].each do |env, hash|

          ssh_host = hash["host"]
          remote_sha = `ssh #{ssh_host} cat app/REVISION`.strip

          if github_table.match(app, remote_sha)
            @rows << [env, app.yellow, remote_sha.green]
          else
            @rows << [env, app.yellow, remote_sha.red]
            str = @updates[env].to_a
            @updates[env] = str << app
          end

        end
      end

      puts Terminal::Table.new(
        :title => "Deployments",
        :headings => ['server', 'app', 'deployed'],
        :rows => @rows
      )
    end

    def apps
      @apps ||= deploy_instructions.fetch("apps")
    end

    def application_branches
      apps.each_with_object({}) do |(env, app_hash), hash|
        hash[env] = app_hash["branch"]
      end
    end

    def github_table
      @github_table ||= GithubTable.new(
        github_account: github_account,
        application_branches: application_branches
      )
    end

    def display_github_shas!
      github_table.fetch_all
      github_table.render
    end

    def deploy_to_outdated_envs!
      @updates.map do |env, apps|
        apps.map do |app|
          puts "Deploying #{app}: #{env}\n".yellow
          thread = Thread.new {
            Deployer.new(env: env, app: app, deploy_instructions: deploy_instructions).deploy
          }
        end
      end
    end
  end
end
