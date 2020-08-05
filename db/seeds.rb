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
User.not_admin.delete_all
UserScore.delete_all
Subscore.delete_all

def generate_user
  pass = Faker::Alphanumeric.alpha(number: 10)
  user = User.new(first_name: Faker::Name.first_name,
                  last_name: Faker::Name.last_name,
                  email: Faker::Internet.email,
                  password: pass,
                  password_confirmation: pass,
                  birthday: Faker::Date.between(from: '1990-07-23', to: '1990-09-24'),
                  role: Faker::Number.within(range: 0..1),
                  locale: "en",
                  use_email: true)
  user.skip_confirmation!
  user.save
  user
end

30.times do
  generate_user
end

10.times do
  event = Event.new(title: Faker::Book.title,
               description: Faker::Quote.matz,
               published: Faker::Boolean.boolean(true_ratio: 0.5),
               startDate: Faker::Date.between(from: 2.days.ago, to: Date.today),
               endDate: Faker::Date.between(from: Date.today, to: 2.days.from_now),
               startTime: Time.now,
               endTime: Time.now + 1,
               location: Faker::Address.full_address,
               eventType: Faker::Number.within(range: 0..2),
               use_email: Faker::Boolean.boolean(true_ratio: 0.5),
               use_text: Faker::Boolean.boolean(true_ratio: 0.5),
               use_call: Faker::Boolean.boolean(true_ratio: 0.5),
               use_app: Faker::Boolean.boolean(true_ratio: 0.5))
  event.users << User.all.sample
  event.save
end

100.times do
  EventStatus.create(event_id: Event.all.sample.id,
                     user_id: User.all.sample.id,
                     state: 0)
end

10.times do
  group = Group.new(name: [Faker::Company.name, Faker::Team.name].sample)
  group.users << User.all.sample
  group.save
end

100.times do
  GroupMembership.create(group_id: Group.all.sample.id,
                         user_id: User.all.sample.id)
end

100.times do
  UserScore.create(user_id: User.all.sample.id)
end

random_subscore_names = ["Basic Needs", "Income", "Housing", "Education", "Health", "Community"]

100.times do
  Subscore.create(user_score_id: UserScore.all.sample.id,
                  name: random_subscore_names.sample,
                  score: Faker::Number.within(range: 0..100),
                  max_score: Faker::Number.within(range: 101..1000))
end

UserScore.all.each do |score|
  subscores = score.subscores
  new_date = Faker::Time.between(from: DateTime.now - 2, to: DateTime.now)
  subscores.each do |subscore|
    subscore.created_at = new_date
    subscore.save
  end
end