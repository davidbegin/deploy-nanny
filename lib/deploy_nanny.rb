require "deploy_nanny/version"
require "deploy_nanny/github_table"
require "deploy_nanny/github_commit"
require "deploy_nanny/deployer"
require "deploy_nanny/base"
require "terminal-table"

module DeployNanny

  class << self
    def babysit(github_account:, deploy_instructions:)
      babysitter = Base.new(
        github_account: github_account,
        deploy_instructions: deploy_instructions
      )

      loop do
        babysitter.babysit
        sleep 60 * 5
      end
    end

  end
end
