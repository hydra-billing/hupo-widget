# Provide a simple gemspec so you can easily use your
# project in your rails apps through git.
Gem::Specification.new do |s|
  s.name = "hupo-widget"
  s.version = "0.1"
  s.authors = ["Nikita Shilnikov", "Latera LLC"]
  s.email = %w(ns@latera.ru)
  s.homepage = "http://github.com/latera/hupo-widget"

  s.summary = "Hydra private office base gem"
  s.description = "Hydra private office base gem"
  s.files = Dir["lib/**/*"] + %w(MIT-LICENSE)

  s.add_dependency('railties', '>= 3.2') # Any rails starting from 3.2

  s.require_paths = %w(lib)
end
