class UsersController < ApplicationController
  before_action :logged_in_user, only: [:edit, :index, :update, :destroy,
                                        :following, :followers]
  before_action :correct_user,   only: [:edit, :update]
  before_action :admin_user,     only: :destroy

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    if @user.save
      # signup success, not yet activate account
      @user.send_activation_email
      flash[:info] = "Please check your email to activate your account."
      redirect_to root_url
    else
      # signup fail
      render 'new'
    end
  end

  def show
    @user = User.find(params[:id])
    @microposts = @user.microposts.page(params[:page])
    redirect_to root_url and return unless @user.activated?
  end

  def edit
    @user = User.find(params[:id])
  end

  def update
    # got `@user` by correct_user
    if @user.update_attributes(user_params)
      # edit success
      flash[:success] = "Profile updated"
      redirect_to @user
    else
      # edit fail
      render 'edit'
    end
  end

  def index
    @users = User.where(activated: true).page(params[:page])
  end

  def destroy
    User.find(params[:id]).destroy
    flash[:success] = "User.deleted"
    redirect_to users_url
  end

  def following
    @title = "Following"
    @user  = User.find(params[:id])
    @users = @user.following.page(params[:page])
    render 'show_follow'
  end

  def followers
    @title = "Followers"
    @user  = User.find(params[:id])
    @users = @user.followers.page(params[:page])
    render 'show_follow'
  end

  private

  def user_params
    params.require(:user).permit(:name, :email, :password,
                                 :password_confirmation)
  end
  
  def correct_user
    @user = User.find(params[:id])
    redirect_to root_url unless current_user?(@user)
  end

  def admin_user
    redirect_to(root_url) unless current_user.admin?
  end
end
