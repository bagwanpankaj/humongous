# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "humongous/version"

Gem::Specification.new do |s|
  s.name = "humongous"
  s.version = Humongous::VERSION

  s.required_rubygems_version = Gem::Requirement.new("> 1.3.1") if s.respond_to? :required_rubygems_version=
  s.required_ruby_version = '>= 1.8.7'
  s.authors = ["bagwanpankaj"]
  s.date = "2014-02-06"
  s.description = "Humongous: A Ruby way to browse and maintain mongo instance. Using HTML5."
  s.email = "bagwanpankaj@gmail.com"
  s.executables = ["humongous"]
  s.extra_rdoc_files = [
    "LICENSE.txt",
    "README.markdown"
  ]
  s.files = [
    "LICENSE.txt",
    "bin/humongous",
    "lib/humongous.rb",
    "lib/humongous/version.rb",
    "lib/humongous/monkey_patch.rb",
    "lib/humongous/helpers.rb",
    "lib/humongous/application.rb",
    "lib/humongous/public/images/favicon.ico",
    "lib/humongous/public/images/ajax-loader.gif",
    "lib/humongous/public/javascripts/application.js",
    "lib/humongous/public/javascripts/bootstrap-modal.js",
    "lib/humongous/public/javascripts/core.js",
    "lib/humongous/public/javascripts/jquery.min.js",
    "lib/humongous/public/javascripts/jquery.nohtml.js",
    "lib/humongous/public/javascripts/query_browser.js",
    "lib/humongous/public/javascripts/storage.js",
    "lib/humongous/public/styles/application.css",
    "lib/humongous/public/styles/bootstrap.min.css",
    "lib/humongous/views/index.erb"
  ]
  s.homepage = "http://github.com/bagwanpankaj/humongous"
  s.licenses = ["MIT"]
  s.require_paths = ["lib"]
  s.rubygems_version = "1.8.10"
  s.summary = "Humongous: A Mongo Browser for Ruby"

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<vegas>, ["= 0.1.8"])
      s.add_runtime_dependency(%q<sinatra>, ["= 1.3.2"])
      s.add_runtime_dependency(%q<bson_ext>, ["= 1.5.2"])
      s.add_runtime_dependency(%q<mongo>, ["= 1.5.2"])
      s.add_runtime_dependency(%q<json>, ["= 1.6.5"])
    else
      s.add_dependency(%q<vegas>, ["= 0.1.8"])
      s.add_dependency(%q<sinatra>, ["= 1.3.2"])
      s.add_dependency(%q<bson_ext>, ["= 1.5.2"])
      s.add_dependency(%q<mongo>, ["= 1.5.2"])
      s.add_dependency(%q<json>, ["= 1.6.5"])
    end
  else
    s.add_dependency(%q<vegas>, ["= 0.1.8"])
    s.add_dependency(%q<sinatra>, ["= 1.3.2"])
    s.add_dependency(%q<bson_ext>, ["= 1.5.2"])
    s.add_dependency(%q<mongo>, ["= 1.5.2"])
    s.add_dependency(%q<json>, ["= 1.6.5"])
  end
end