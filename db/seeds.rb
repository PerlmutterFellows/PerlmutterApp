User.delete_by(admin: false)
Group.delete_by(visible: true)

50.times do
  pass = Faker::Alphanumeric.alpha(number: 10)
  user = User.new(first_name: Faker::Name.first_name,
                  last_name: Faker::Name.last_name,
                  email: Faker::Internet.unique.email,
                  password: pass,
                  password_confirmation: pass)
  user.skip_confirmation!
  if user.valid?
    user.save
  end
end

50.times do
  pass = Faker::Alphanumeric.alpha(number: 10)
  user = User.new(first_name: Faker::Name.first_name,
                  last_name: Faker::Name.last_name,
                  phone_number: Faker::PhoneNumber.cell_phone,
                  password: pass,
                  password_confirmation: pass)
  user.skip_confirmation!
  if user.valid?
    user.save
  end
end

20.times do
  group = Group.new(name: [Faker::Company.name, Faker::Team.name].sample,
                    visible: true)
  if group.valid?
    group.save
    group.users = User.all.sample(rand(1..10))
  end
end