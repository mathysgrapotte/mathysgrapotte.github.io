# -*- encoding: utf-8 -*-
# stub: jektex 0.1.1 ruby lib

Gem::Specification.new do |s|
  s.name = "jektex".freeze
  s.version = "0.1.1".freeze

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.metadata = { "bug_tracker_uri" => "https://github.com/yagarea/jektex/issues", "changelog_uri" => "https://github.com/yagarea/jektex/blob/master/changelog.md", "documentation_uri" => "https://github.com/yagarea/jektex/blob/master/README.md", "homepage_uri" => "https://github.com/yagarea/jektex", "source_code_uri" => "https://github.com/yagarea/jektex" } if s.respond_to? :metadata=
  s.require_paths = ["lib".freeze]
  s.authors = ["Jan \u010Cern\u00FD".freeze]
  s.date = "2023-10-24"
  s.description = "Highly optimized and cached latex server side rendering for Jekyll with macros and dynamic output".freeze
  s.email = "jc@ucw.cz".freeze
  s.homepage = "https://github.com/yagarea/jektex".freeze
  s.licenses = ["GPL-3.0-or-later".freeze]
  s.required_ruby_version = Gem::Requirement.new(">= 2.7.0".freeze)
  s.rubygems_version = "3.3.25".freeze
  s.summary = "Highly optimized latex rendering for Jekyll".freeze

  s.installed_by_version = "3.6.5".freeze

  s.specification_version = 4

  s.add_runtime_dependency(%q<execjs>.freeze, ["~> 2.1".freeze, ">= 2.9.1".freeze])
  s.add_runtime_dependency(%q<digest>.freeze, ["~> 3.1.1".freeze, ">= 3.1.1".freeze])
  s.add_runtime_dependency(%q<htmlentities>.freeze, ["~> 4.3".freeze, ">= 4.3.4".freeze])
  s.add_development_dependency(%q<bundler>.freeze, ["~> 2.0".freeze, ">= 2.0.0".freeze])
end
