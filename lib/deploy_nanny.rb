require "deploy_nanny/version"
require "deploy_nanny/github_table"
require "deploy_nanny/github_commit"
require "deploy_nanny/deployer"
require "deploy_nanny/base"
require "tty-progressbar"
require "terminal-table"
require "optparse"
require "ostruct"

module DeployNanny

  class << self
    def babysit(github_account:, deploy_instructions:)

      options = {}
      OptionParser.new do |opts|
        opts.banner = "\nUsage: bin/your_exec [options]\n".yellow

        opts.on("-n", "--no-deploy", "Do not auto-deploy out-of-date apps") do
          options[:no_deploy] = true
        end

        opts.on_tail("-h", "--help", "Here are all the options Deploy Nanny takes") do
          puts opts
          exit
        end
      end.parse!
      options = OpenStruct.new(options)

      babysitter = Base.new(
        github_account: github_account,
        deploy_instructions: deploy_instructions,
        options: options
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

