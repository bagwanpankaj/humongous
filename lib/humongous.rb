require 'rubygems'
# require 'bundler'
# require "bundler/setup"

require "sinatra/base"
require "mongo"
require "json"
require "crack"
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

  def self.run!
    puts "Hi There, Welcome and thanks for using Humongous."
    puts "Welcome aboard Humongous."

    Application.run!
  end

end