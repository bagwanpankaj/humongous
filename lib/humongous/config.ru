require 'rubygems'
require "sinatra/base"
require "mongo"
require "json"
require './monkey_patch'
require './helpers'
require './application'
require './version'
Humongous::Application.run!