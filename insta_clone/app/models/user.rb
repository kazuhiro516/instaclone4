class User < ApplicationRecord
  has_many :posts,   dependent: :destroy
  has_many :likes,   dependent: :destroy
  has_many :comments,dependent: :destroy
  # フォロー機能のアソシエーション
  has_many :following_relationships, foreign_key: "follower_id", 
                                      class_name: "Relationship", 
                                       dependent: :destroy
  
  has_many :followings, through: :following_relationships,dependent: :destroy

  has_many :follower_relationships, foreign_key: "following_id", 
                                     class_name: "Relationship", 
                                      dependent: :destroy

  has_many :followers, through: :follower_relationships
  # 通知機能のアソシエーション
  has_many :active_notifications,  class_name: 'Notification', 
                                  foreign_key: 'visitor_id', dependent: :destroy
  has_many :passive_notifications, class_name: 'Notification', 
                                  foreign_key: 'visited_id', dependent: :destroy

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable, :recoverable, :rememberable, :validatable, :omniauthable, omniauth_providers: %i[facebook]
  validates :name, presence: true, length: { maximum: 50 }
  validates :introduction, presence: false, length: { maximum: 160 }
  # フォロー機能
  def following?(other_user)
    following_relationships.find_by(following_id: other_user.id)
  end

  def follow!(other_user)
    following_relationships.create!(following_id: other_user.id)
  end

  def unfollow!(other_user)
    following_relationships.find_by(following_id: other_user.id).destroy
  end

  # パスワードを入力せずにプロフィールを変更する
  def update_without_current_password(params, *options)
    params.delete(:current_password)

    if params[:password].blank? && params[:password_confirmation].blank?
      params.delete(:password)
      params.delete(:password_confirmation)
    end

    result = update(params, *options)
    clean_up_passwords
    result
  end

  # FBログイン
  def self.from_omniauth(auth)
    where(provider: auth.provider, uid: auth.uid).first_or_create do |user|
      user.email = auth.info.email
      user.password = Devise.friendly_token[0,20]
      user.name = auth.info.name   # assuming the user model has a name
      # user.image = auth.info.image # assuming the user model has an image
      # If you are using confirmable and the provider(s) you use validate emails, 
      # uncomment the line below to skip the confirmation emails.
      # user.skip_confirmation!
    end
  end
  # フォロー通知のメソッド
  def create_notification_follow!(current_user)
    temp = Notification.where(["visitor_id = ? and visited_id = ? and action = ? ",current_user.id, id, 'follow'])
    if temp.blank?
      notification = current_user.active_notifications.new(
        visited_id: id,
        action: 'follow'
      )
      notification.save if notification.valid?
    end
  end
end
