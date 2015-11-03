require_relative "deployer"
require 'spinning_cursor'

module DeployNanny
  class Base
    def initialize(github_account:,
                   nannyrc:,
                   environments:,
                   deploy_instructions:,
                   options: {})

      @github_account      = github_account
      @nannyrc             = nannyrc
      @environments        = environments
      @deploy_instructions = deploy_instructions
      @options             = options
      @rows                = []
      @updates             = {}
    end

    def babysit
      display_github_shas!
      display_deployed_shas!
      deploy_to_outdated_envs! unless options.no_deploy
      clear_memoized_values!
    end

    private

    attr_reader :github_account,
                :nannyrc,
                :environments,
                :deploy_instructions,
                :options

    def clear_memoized_values!
      @updates      = {}
      @rows         = []
      @github_table = nil
    end

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
      apps.each do |app|
        envs.each do |env|
          host       = environments.fetch(env).fetch("host")
          ssh_host   = "#{app}@#{host}"
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

    def envs
      @envs ||= deploy_instructions.fetch("envs")
    end

    def apps
      @apps ||= deploy_instructions.fetch("apps").keys
    end

    def application_branches
      deploy_instructions.fetch("apps")
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
      @updates.each do |env, apps|
        apps.each do |app|
          puts "Deploying #{app}: #{env}\n".yellow
          deployer = Deployer.new(
            env: env,
            app: app,
            nannyrc: nannyrc,
            environments: environments,
            deploy_instructions: deploy_instructions
          )
          puts deployer.command
          deployer.deploy
        end
      end
    end
  end
end
