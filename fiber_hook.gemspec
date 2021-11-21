# frozen_string_literal: true

require_relative "lib/fiber_hook/version"

Gem::Specification.new do |spec|
  spec.name          = "fiber_hook"
  spec.version       = FiberHook::VERSION
  spec.authors       = ["Brian Morearty"]
  spec.email         = ["brian@morearty.org"]

  spec.summary       = "Lets you hook into Fiber.new and Fiber.resume"
  spec.description   = "Lets you hook into Fiber.new and Fiber.resume"
  spec.homepage      = "https://github.com/BMorearty/fiber_hook"
  spec.license       = "MIT"
  spec.required_ruby_version = ">= 2.5.0"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
  spec.metadata["changelog_uri"] = "#{spec.homepage}/blob/master/CHANGELOG.md"
  spec.metadata["rubygems_mfa_required"] = "true"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject do |f|
      f.match(%r{\A(?:test|spec|features)/})
    end
  end
  spec.require_paths = ["lib"]

  # Uncomment to register a new dependency of your gem
  # spec.add_dependency "example-gem", "~> 1.0"
end
