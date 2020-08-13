require 'bundler/setup'
Bundler.require
require "sinatra/reloader"
dbconfig = SequelDbConfig::Config.instance
DB = Sequel.connect(dbconfig.connection_string)
Dir.glob('./{models,lib,helpers}/*.rb').each { |file| require file }