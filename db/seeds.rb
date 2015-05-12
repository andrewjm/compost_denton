# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

# run with rake db:seed
# reset db with bundle exec rake db:migrate:reset

User.create!( name:                  'Admin User',
	      email:                 'admin@dbseeds.com',
	      password:              'foobar',
	      password_confirmation: 'foobar',
	      admin:                  true )

99.times do |n|
  name     = Faker::Name.name
  email    = "user_#{n+1}@dbseeds.com"
  password = 'password'
  User.create!( name:                  name,
		email:                 email,
		password:              password,
		password_confirmation: password )
end
