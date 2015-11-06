# DeployNanny

Some help with managing deploying multiple-apps and multiple-branches to multiple-environments.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'deploy_nanny'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install deploy_nanny

## Usage

With an executable file called bin/babysit containing the following:
```ruby
#!/usr/bin/env ruby

require "deploy_nanny"
require "yaml"

environments        = YAML.load_file("environments.yml")
deploy_instructions = YAML.load_file("deploy_instructions.yml")
nannyrc             = YAML.load_file(".nannyrc")

DeployNanny.babysit(
  github_account: "yourgithubname",
  nannyrc: nannyrc,
  environments: environments,
  deploy_instructions: deploy_instructions,
)

```

Create a .nannyrc to specify were all your apps are stored.
This means you have to have every app nested in the same directory for Mrs. Doubtfire to work.

# .nannyrc
```
apps_directory: "/Users/username/app_folder"
```

##### Options
```bash
-h, --help                       Here are all the options Deploy Nanny takes
-n, --no-deploy                  Do not auto-deploy out-of-date apps
-s, --sleep=SLEEP                Time to sleep between sweeps in minutes.
```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/deploy_nanny. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](contributor-covenant.org) code of conduct.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

