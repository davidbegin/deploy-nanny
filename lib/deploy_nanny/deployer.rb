require "open3"

module DeployNanny
  class Deployer

    def initialize(env:, app:, deploy_instructions:)
      @env                 = env
      @app                 = app
      @deploy_instructions = deploy_instructions
    end

    def deploy
      Bundler.with_clean_env {
        Dir.chdir("#{dir}/") {
          cmd = "bundle install && #{command}"
          output, status = Open3.capture2(cmd)
        }
      }
    end

    private

    attr_reader :env, :app, :deploy_instructions

    def command
      cmd = command_template.dup
      deploy_config.fetch("variables").each do |var|
        cmd.sub!(":#{var}:", deploy_info(var))
      end
      cmd
    end

    def command_template
      deploy_config.fetch("command_template")
    end

    def dir
      deploy_config.fetch("directory")
    end

    def revision
      deploy_config.fetch("branch")
    end

    # This is specific to personal use
    def user
      @user ||= env.dup.sub!(".dev", "")
    end

    def deploy_info(var)
      case var
      when "revision"
        revision
      when "user"
        user
      end
    end

    def deploy_config
      @deploy_config ||= deploy_instructions.fetch(app)
    end
  end
end
