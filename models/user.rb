require "etc"

class User < Sequel::Model
  # id : primary_key
  # uid : UID
  # gid : GID
  # username : ユーザ名
  # password : パスワード
  # home_dir : ホームディレクトリ
  # forward_address : 転送先アドレス
  # forwarded : 転送設定がされているかどうか (true / false)

  plugin :validation_helpers

  EMAIL_REGEXP = /\A[A-Za-z0-9+_\-.]+@[A-Za-z0-9+_\-.]+\Z/
  MIN_PASSWORD_LEN = 6

  def validate
    super
    validates_presence [:username], :message => "ユーザ名が指定されていません。"
    validates_presence [:password], :message => "パスワードが指定されていません。"
    validates_presence [:home_dir], :message => "ホームディレクトリが指定されていません。"
    validates_unique :username, :message => "指定されたユーザ名はすでに登録されています。"
    validates_min_length MIN_PASSWORD_LEN, :password, :message => "パスワードは#{MIN_PASSWORD_LEN}文字以上で指定してください。"
    if username
      if uid.nil? || gid.nil?
        errors.add(:username, "指定されたユーザ名 #{username} はシステムに存在しません。")
      end
      errors.add(:uid, "UID/GIDが正しくありません。") if !User.check_user(username, uid, gid)
    end
    if forwarded # 転送設定がされている
      validates_format EMAIL_REGEXP, :forward_address, :message => "転送先アドレスの形式が正しくありません。"
    end
  end

  def before_validation
    if username
      Etc::Passwd.each do |entry|
        if (entry.name == username)
          self.uid ||= entry.uid
          self.gid ||= entry.uid
          self.home_dir ||= entry.dir
        end
      end
    end
    super
  end

  def to_hash
    { :uid => uid,
      :gid => gid,
      :username => username,
      :my_address => my_address,
      :home_dir => home_dir,
      :forwarded => forwarded,
      :forward_address => forward_address }
  end

  def password=(new_password)
    if new_password.to_s == ""
      raise "空のパスワードは指定できません。"
    end
    self[:password] = User.generate_password_hash(new_password)
  end

  def my_address
    config = AppConfig.instance
    "#{username}@#{config.my_domain}"
  end

  def check_password(pw)
    config = AppConfig.instance
    cmd = "#{config.doveadm} pw -p '#{pw}' -t '#{self.password}' 2>&1"
    result = `#{cmd}` =~ /verified/
    !result.nil?
  end

  def set_forward(address)
    unless address =~ EMAIL_REGEXP
      raise "転送先メールアドレスの形式が正しくありません。"
    end
    if address == my_address
      raise "転送先メールアドレスに自分自身のアドレスは指定できません。"
    end
    self.forwarded = true
    self.forward_address = address.to_s
    self.save
  end

  def disable_forward
    self.forwarded = false
    self.save
  end

  private
  def User.generate_password_hash(pw)
    config = AppConfig.instance
    cmd = "#{config.doveadm} pw -s #{config.pw_scheme} -p #{pw}"
    `#{cmd}`.chomp
  end

  def User.check_user(name, uid, gid)
    Etc::Passwd.each do |entry|
      if entry.name == name && entry.uid == uid && entry.gid == gid
        return true
      end
    end
    false
  end

  def User.find_by_username(name)
    User.where(:username => name).first
  end
end
