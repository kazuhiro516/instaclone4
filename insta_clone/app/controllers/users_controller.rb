class UsersController < ApplicationController
  before_action :authenticate_user!

  def index
    @user_all = User.includes(:user).page(params[:page])
  end

  def show
    @user = User.find(params[:id])
    @post = Post.where(user_id: params[:id]).order(created_at: :desc)
  end

  def destroy
    @user = User.find(params[:id]) 
    @user.destroy
    flash[:success] = 'ユーザーを削除しました。'
    redirect_to root_path
  end

  def following
    @user  = User.find(params[:id])
    @users = @user.followings
    render 'show_follow'
  end

  def followers
    @user  = User.find(params[:id])
    @users = @user.followers
    render 'show_follow'
  end
end
