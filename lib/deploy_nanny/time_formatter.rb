module DeployNanny
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
