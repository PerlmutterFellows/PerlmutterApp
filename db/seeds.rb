# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)
require 'faker'

Event.delete_all
EventStatus.delete_all
Group.delete_all
GroupMembership.delete_all
User.delete_by(admin: false)

10.times do
  Event.create(title: Faker::Book.title,
               description: Faker::Quote.matz,
               published: Faker::Boolean.boolean(true_ratio: 0.5),
               startDate: Faker::Date.between(from: 2.days.ago, to: Date.today),
               endDate: Faker::Date.between(from: Date.today, to: 2.days.from_now),
               startTime: Time.now,
               endTime: Time.now + 1,
               location: Faker::Address.full_address,
               eventType: Faker::Number.within(range: 0..2))
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

100.times do
  EventStatus.create(event_id: Event.all.sample.id,
                     user_id: User.all.sample.id,
                     state: 0)
end

10.times do
  Group.create(name: [Faker::Company.name, Faker::Team.name].sample)
end

100.times do
  GroupMembership.create(group_id: Group.all.sample.id,
                         user_id: User.all.sample.id)
end
