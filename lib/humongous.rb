require 'rubygems'
require "sinatra/base"
require "mongo"
require "json"
require 'humongous/monkey_patch'
require 'humongous/helpers'
require 'humongous/application'
require 'humongous/version'

module Humongous

  def self.root
    File.dirname(File.expand_path('..', __FILE__))
  end

  #gem version
  def self.version #:nodoc
    Humongous::VERSION
  end

  def self.description
    %Q{
      Humongous: A Ruby way to browse and maintain mongo instance. Using HTML5.
      This is beta version, So there is long way to go, but still you can enjoy its
      simplistic design.
    }
  end

  def self.summary
    %Q{An standalone Mongo Browser for Ruby. Just run and forget.}
  end

  def self.copyright
    "Bagwan Pankaj 2012-2020"
  end

  def self.author
    "Bagwan Pankaj"
  end

  def self.run!
    puts "#################################################"
    puts "You are using Humongous(#{Humongous.version})"
    puts "Welcome aboard on Humongous. Enjoy!"
    puts "#################################################"

    Application.run!
  end

end
