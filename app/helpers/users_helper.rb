module UsersHelper

  def get_user_photo(user)
    if user.photo?
      photo = user.photo
    elsif user.facebook_picture_url.nil? == false
      photo = user.facebook_picture_url
    elsif user.picture_url.nil? == false
      photo = user.picture_url
    else
      photo = "blank-profile-picture.svg"
    end
    photo
  end

end
