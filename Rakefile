# coding: utf-8
require "sequel"
require "sequel_db_config"

desc "Migration"
task :migrate, [:version] do |task, args|
  if args.version
    opt = "-M #{args.version}"
  end
  dbconfig = SequelDbConfig::Config.instance
  cmd = "sequel #{opt} -m ./migrations/ #{dbconfig.connection_string}"
  `#{cmd}`
end

desc "Run server"
task :run, [:port] do |task, args|
  port = args.port.to_i
  if port == 0
    port = "4321"
  end
  cmd = "bundle exec rackup -p #{port} -s puma -o 0.0.0.0"
  `#{cmd}`
end
