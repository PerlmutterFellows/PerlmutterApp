module GroupsHelper

  ##
  # Returns unique selected users from select array containing group and user ids
  # select - an array containing user ids (no extra prefix), and group ids (prefixed with 'g' to distinguish)
  def get_users_from_select(select)
    select = select.reject { |id| id.blank? }
    users = []
    select.each do |user_id|
      user = User.find_by_id(user_id)
      group = Group.find_by_id(user_id.sub! "g","")
      if !user.blank?
        users.push(user)
      elsif !group.blank?
        users = (users + get_users_from_select(group.users.map { |user| user.id.to_s }))
      end
    end
    users.uniq { |user| user.id }
  end

  ##
  # Returns a modified version of provided users where a user already in the group does not get overwritten, maintaining its values
  # users - an array of users
  # group - a group containing users
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
