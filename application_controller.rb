require "sinatra/reloader"

class ApplicationController < Sinatra::Base
    helpers Sinatra::JSON
    helpers ApplicationHelper

    configure do
        enable :sessions
        enable :logging
    end

    configure :development do
        register Sinatra::Reloader
    end

    get "/" do
        config = AppConfig.instance
        @my_domain = config.my_domain
        erb :index
    end

    get "/info" do
        config = AppConfig.instance
        info = {
            my_domain: config.my_domain
        }
        json info
    end

    # ユーザ認証
    # params[:username] : ユーザ名
    # params[:password] : パスワード
    post "/auth" do
        begin
            user = User.find_by_username(params[:username])
            if user.nil? || !user.check_password(params[:password])
                session[:user_id] = nil
                halt 403, "Invalid username or password"
            else
                session[:user_id] = user.id
                json user.to_hash
            end
        rescue => ex
            logger.error "[ERROR] auth error: #{ex.message}"
            halt 500
        end
    end

    # ユーザ情報の取得
    get "/user" do
        begin
            authorized?
            json @user.to_hash
        rescue => ex
            logger.error "[ERROR] user error: #{ex.message}"
            halt 500, ex.message
        end
    end

    # パスワードの変更
    # params[:current_password] : 現在のパスワード
    # params[:new_password] : 新しいパスワード
    post "/password" do
        begin
            authorized?
            if @user.check_password(params[:current_password])
                @user.password = params[:new_password]
                @user.save
            else
                raise "パスワードが正しくありません。"
            end
            json @user.to_hash
        rescue => ex
            logger.error "[ERROR] password error: #{ex.message}"
            halt 500, ex.message
        end 
    end

    # 転送設定の変更
    # params[:forwarded] : 転送の有無
    # params[:forward_address] : 転送先メールアドレス
    post "/forward" do
        begin
            authorized?
            if params[:forwarded] == "true"
                @user.set_forward params[:forward_address]
            else
                @user.disable_forward
            end
            json @user.to_hash
        rescue => ex
            logger.error "[ERROR] forward error: #{ex.message}"
            halt 500, ex.message
        end
    end

    # ログアウト
    post "/logout" do
        session.clear
        redirect to("/")
    end
end
