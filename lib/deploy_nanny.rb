require "deploy_nanny/version"
require "deploy_nanny/github_table"
require "deploy_nanny/github_commit"
require "terminal-table"

module DeployNanny

  class << self

    def babysit(remote_hosts:, github_account:, application_branches:)
      github_table = GithubTable.new(
        github_account: github_account,
        application_branches: application_branches
      )
      github_table.fetch_all
      github_table.render

      host_groups = ["dev_user"]
      rows        = []
      @updates    = {}

      host_groups.each do |host_group|
        remote_hosts[host_group].each do |host_hash|
          host_hash.each do |name, apps|
            @updates[name] = []
            apps['apps'].each do |app, ssh_host|
              # This could be different for different deployed app setups
              remote_sha = `ssh #{ssh_host} cat app/REVISION`.strip
              if github_table.match(app, remote_sha)
                rows << [name, app.yellow, remote_sha.green]
              else
                rows << [name, app.yellow, remote_sha.red]
                @updates[name] << app
              end
            end
            rows << :separator
          end
        end
      end

      rows.pop
      puts Terminal::Table.new(
        :title => "Deployments",
        :headings => ['server', 'app', 'deployed'],
        :rows => rows
      )
      display_updates
    end

    private

    def display_updates
      puts "\n\nAvailable Updates:\n"

      @updates.each do |host|
        next if host[1].empty?
        puts "#{host[0]} => " + host[1].join(" and ")
      end
    end

  end
end
