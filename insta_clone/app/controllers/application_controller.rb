class ApplicationController < ActionController::Base
  # CSRFへの対策コード
  protect_from_forgery with: :exception
  # ストロングパラメーターの追加
  before_action :configure_permitted_parameters, if: :devise_controller?
  # 検索フォーム
  before_action :set_search

  def after_sign_in_path_for(resource) 
    posts_path
  end

   def after_sign_out_path_for(resource)
    root_path 
  end

  def set_search
    @search = User.ransack(params[:q]) 
    @search_users = @search.result.page(params[:page])
  end

  protected

    def configure_permitted_parameters
      devise_parameter_sanitizer.permit(:sign_up, keys: [:name])
      devise_parameter_sanitizer.permit(:account_update, keys: [:name, :introduction])
    end
end
