module UsersHelper
    # before_action :require_valid_user!
    def current_user
        if !session[:user_id].blank?
            @user ||= User.find(session[:user_id])
        end
    end

    def require_valid_user!
        if current_user.nil?
            flash[:error] = 'You must be logged in to access that page!'
            redirect_to user_login_path
        end
    end

    def user_logged_in?
        !current_user.nil?
    end
end
