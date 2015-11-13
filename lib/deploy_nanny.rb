require_relative "deploy_nanny/version"
require_relative "deploy_nanny/github_table"
require_relative "deploy_nanny/github_commit"
require_relative "deploy_nanny/deployer"
require_relative "deploy_nanny/base"
require "tty-progressbar"
require "terminal-table"
require "optparse"
require "ostruct"

module DeployNanny

  class << self
    def babysit(github_account:,
                nannyrc:,
                environments:,
                deploy_instructions:)

      @options = OpenStruct.new(parse_options)

      babysitter = Base.new(
        github_account: github_account,
        nannyrc: nannyrc,
        environments: environments,
        deploy_instructions: deploy_instructions,
        options: @options
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
      @options.sleep || 60 * 5
    end

    def parse_options
      options = {}
      OptionParser.new do |opts|
        opts.banner = "\nUsage: bin/your_exec [options]\n".yellow

        opts.on("-n", "--no-deploy", "Do not auto-deploy out-of-date apps") do
          options[:no_deploy] = true
        end

        opts.on("-s", "--sleep=SLEEP", "Time to sleep between sweeps in minutes.") do |sleep|
          options[:sleep] = sleep.to_i * 60
        end

        opts.on_tail("-h", "--help", "Here are all the options Deploy Nanny takes") do
          puts opts
          exit
        end
      end.parse!
      options
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

