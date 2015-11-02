require "deploy_nanny/version"
require "deploy_nanny/github_table"
require "deploy_nanny/github_commit"
require "deploy_nanny/deployer"
require "deploy_nanny/base"
require "tty-progressbar"
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

        bar = TTY::ProgressBar.new(":time", total: sweep_rest) do |config|
          config.hide_cursor = true
        end
        bar.use TimeFormatter

        sweep_rest.times do
          sleep(1)
          bar.advance(1)
        end
      end
    end

    def sweep_rest
      60 * 5
    end

  end

  class TimeFormatter
    def initialize(progress)
      @progress = progress
    end

    def matches?(value)
      value.to_s =~ /:time/
    end

    def format(value)
      time = Time.at((DeployNanny.sweep_rest - @progress.current)).utc.strftime("%M:%S")
      formatted_str = "Time remaining before next sweep and deploy: #{time}".yellow
      value.gsub(/:time/, formatted_str)
    end
  end
end

