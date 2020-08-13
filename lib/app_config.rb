require "yaml"
require "singleton"
require "digest/md5"

class AppConfig
  include Singleton
  CONFIG_FILE = File.expand_path("../../config.yaml", __FILE__)
  attr_reader :my_domain, :doveadm, :pw_scheme

  def initialize
    @my_domain = nil
    @admin_user = nil
    @admin_password = nil
    @doveadm = nil
    @pw_scheme
    load
  end

  def load
    if File.exists?(CONFIG_FILE)
      data = YAML.load(IO.read(CONFIG_FILE))
      @my_domain = data["my_domain"]
      @admin_user = data["admin_user"]
      @admin_password = data["admin_password"]
      @doveadm = data["doveadm"]
      @pw_scheme = data["pw_scheme"]
    end
  end

  def admin_auth(user, password)
    password_hash = Digest::MD5.hexdigest(password)
    user == @admin_user && password_hash == @admin_password
  end
end
