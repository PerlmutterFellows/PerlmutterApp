module UsersHelper
  def user_is_admin?
    current_user && current_user.admin
  end
end
