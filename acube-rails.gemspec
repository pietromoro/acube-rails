require_relative "lib/acube/version"

Gem::Specification.new do |spec|
  spec.name        = "acube-rails"
  spec.version     = ACube::VERSION
  spec.authors     = ["Pietro Moro"]
  spec.email       = ["pietro@pietromoro.dev"]
  spec.homepage    = "https://github.com/pietromoro/acube-rails"
  spec.summary     = "ACube api wrapper for rails"
  spec.description = "ACube api wrapper for rails"
  spec.license     = "MIT"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the "allowed_push_host"
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  # spec.metadata["allowed_push_host"] = "TODO: Set to 'http://mygemserver.com'"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/pietromoro/acube-rails"
  spec.metadata["changelog_uri"] = "https://github.com/pietromoro/acube-rails/blob/master/CHANGELOG.md"

  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]
  end

  spec.add_dependency "rails", ">= 7.0.0"
  spec.add_dependency "pg", ">= 1.0"
  spec.add_dependency 'faraday', '~> 2.7', '>= 2.7.6'
end
