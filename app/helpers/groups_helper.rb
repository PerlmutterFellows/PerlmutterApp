module GroupsHelper

  def get_users_from_select(select)
    select = select.reject { |id| id.blank? }
    users = []
    select.each do |user_id|
      user = User.find_by_id(user_id)
      group = Group.find_by_id(user_id.sub! "g","")
      if !user.blank?
        users.push(user)
      elsif !group.blank?
        users = (users + get_users_from_select(group.users.map { |user| user.id.to_s })).uniq
      end
    end
    users
  end

  def maintain_state(users, group)
    users.each do |user|
      if group.users.exists?(user.id)
        user = group.users.find(user.id)
        user.save
      end
    end
    users
  end
end
