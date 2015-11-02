require "deploy_nanny/version"
require "deploy_nanny/github_table"
require "deploy_nanny/github_commit"
require "deploy_nanny/deployer"
require "terminal-table"

module DeployNanny

  class << self

    def babysit(remote_hosts:,
                github_account:,
                application_branches:,
                deploy_instructions:)

      @deploy_instructions = deploy_instructions

      loop do
        github_table = GithubTable.new(
          github_account: github_account,
          application_branches: application_branches
        )
        github_table.fetch_all
        github_table.render

        rows        = []
        @updates    = {}

        remote_hosts.each do |env, host_hash|
          @updates[env] = []
          host_hash['apps'].each do |app, ssh_host|

            # This is specfic to personal use
            remote_sha = `ssh #{ssh_host} cat app/REVISION`.strip

            if github_table.match(app, remote_sha)
              rows << [env, app.yellow, remote_sha.green]
            else
              rows << [env, app.yellow, remote_sha.red]
              @updates[env] << app
            end
          end
          rows << :separator
        end

        rows.pop
        puts Terminal::Table.new(
          :title => "Deployments",
          :headings => ['server', 'app', 'deployed'],
          :rows => rows
        )
        execute_updates

        sleep 60
      end
    end

    private

    def execute_updates
      @updates.map do |env, apps|
        apps.map do |app|
          thread = Thread.new {
            Deployer.new(env: env, app: app, deploy_instructions: @deploy_instructions).deploy
          }
        end
      end
    end

  end
end
