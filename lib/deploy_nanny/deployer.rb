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
      deploy_instructions.fetch("deploy_variables").each do |var|
        cmd.sub!(":#{var}:", deploy_info(var))
      end
      cmd
    end

    def command_template
      deploy_instructions.fetch("deploy_template")
    end

    def dir
      deploy_instructions.fetch("apps_directory") + "/#{app}"
    end

    def revision
      apps_config.fetch("branch")
    end

    def deploy_info(var)
      case var
      when "revision"
        revision
      when "user"
        env
      when "cap_env"
        apps_config["envs"][env]["cap_env"]
      end
    end

    def apps_config
      @apps_config ||= deploy_instructions.fetch("apps").fetch(app)
    end
  end
end
