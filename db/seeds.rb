# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)



unless Rails.env.production?

  emails = [
    'reviewer1@example.com',
    'qa@bodleian.com',
    'test@bodleian.com',
    'test2@bodleian.com',
    'archivist1@example.com'
  ]
  
  emails.each do |email|   
    User.find_or_create_by(email: email) do |user|
      user.password = 'password'
    end  
  end

end
