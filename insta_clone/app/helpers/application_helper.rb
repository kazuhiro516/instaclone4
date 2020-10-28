module ApplicationHelper
  def avatar_url(user)
    return user.profile_photo unless user.profile_photo.nil?
    gravatar_id = Digest::MD5::hexdigest(user.email).downcase
    "https://www.gravatar.com/avatar/#{gravatar_id}.jpg"
  end

  def default_meta_tags
    {
      site: 'InstaClone',
      reverse: true,
      separator: '|',
      og: defalut_og,
    }
  end

  private

    def defalut_og
      {
        title: :full_title,
        description: 'まるでInstagramのような写真投稿SNSです。',
        url: request.url,
        image: 'https://example.com/hoge.png'
      }
    end
end
