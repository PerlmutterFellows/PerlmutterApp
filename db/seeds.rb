# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)
require 'faker'

Event.delete_all

100.times do
  event = Event.create(
      title: Faker::Book.title,
      description: Faker::Quote.matz,
      published: Faker::Boolean.boolean(true_ratio: 0.5),
      startDate: Faker::Date.between(from: 2.days.ago, to: Date.today),
      endDate: Faker::Date.between(from: Date.today, to: 2.days.from_now),
      startTime: Time.now,
      endTime: Time.now + 1,
      location: Faker::Address.full_address,
      eventType: Faker::Number.within(range: 0..2),
      to: 1
  )
end
