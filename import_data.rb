#!/usr/bin/env ruby
require "sequel"
require "pg"
require "sequel_db_config"
require "./lib/app_config"

def usage
    STDERR.print <<EOS
#{$0} text_file
EOS
end

if ARGV.length < 1
    usage
    exit 1
end

config = AppConfig.instance
dbconfig = SequelDbConfig::Config.instance
DB = Sequel.connect(dbconfig.connection_string)
DB[:users].delete
DB.transaction do
    IO.foreach(ARGV[0]) do |line|
        fields = line.chomp.split("\t")
        case fields.count
        when 8
            # new format (without password_scheme)
            (id, uid, gid, username, password, home_dir, forward_address, forwarded) = fields         
        when 9
            # old format (with password_scheme)
            (id, uid, gid, username, password_scheme, password, home_dir, forward_address, forwarded) = fields
            password = `doveadm pw -s #{config.pw_scheme} -p '#{password}'`.chomp
        else
            raise "Invalid text format"
        end
        user = {
            uid: uid.to_i,
            gid: gid.to_i,
            username: username,
            password: password,
            home_dir: home_dir,
            forward_address: forward_address == "\\N" ? "" : forward_address,
            forwarded: forwarded == "t",
        }
        DB[:users].insert_conflict.insert(user)
    end
end