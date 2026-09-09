require_relative "lib/flight_control/version"

Gem::Specification.new do |spec|
  spec.name = "flight_control"
  spec.version = FlightControl::VERSION
  spec.authors = ["Jury Razumau"]
  spec.email = ["mail@razumau.net"]
  spec.homepage = "https://github.com/razumau/flight_control"
  spec.summary = "A Solid Queue dashboard for Active Job"
  spec.license = "MIT"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
  spec.metadata["changelog_uri"] = "#{spec.homepage}/blob/main/CHANGELOG.md"

  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    Dir["{app,config,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md", "CHANGELOG.md"]
      .reject { |f| File.basename(f) == ".DS_Store" }
  end

  rails_version = ">= 8.1"
  spec.add_dependency "activerecord", rails_version
  spec.add_dependency "activejob", rails_version
  spec.add_dependency "actionpack", rails_version
  spec.add_dependency "actioncable", rails_version
  spec.add_dependency "railties", rails_version
  spec.add_dependency "importmap-rails", ">= 1.2.1"
  spec.add_dependency "turbo-rails"
  spec.add_dependency "stimulus-rails"
  spec.add_dependency "irb", "~> 1.13"
  spec.add_dependency "solid_queue", ">= 1.0"

  spec.add_development_dependency "minitest", "~> 6.0"
  spec.add_development_dependency "selenium-webdriver"
  spec.add_development_dependency "mocha"
  spec.add_development_dependency "debug"
  spec.add_development_dependency "rubocop"
  spec.add_development_dependency "rubocop-performance"
  spec.add_development_dependency "standard"
  spec.add_development_dependency "better_html"
  spec.add_development_dependency "propshaft"
  spec.add_development_dependency "sqlite3"
  spec.add_development_dependency "puma"
end
