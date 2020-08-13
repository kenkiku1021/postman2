module ApplicationHelper
    def authorized?
        if session[:user_id].nil?
            halt 403, "Not authorized"
        else
            @user = User[session[:user_id]]
            true
        end
    end
end