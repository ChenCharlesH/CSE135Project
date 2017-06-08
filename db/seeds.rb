# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

User.create(unique_name: "SKK", password: "topkek", owner: true, age:50, state: "CA", created_at: Time.now, updated_at:Time.now)

maxUsersPerGroup = 100

# Generate owners
maxUsersPerGroup.times do |i|
  create = Faker::Date.between(10.days.ago, Date.today)
  update = Faker::Date.between(create, Date.today)
  state = Faker::Address.state_abbr
  User.create(unique_name: Faker::Name.unique.name, password: "topkek", owner: true, age:50, state: state, created_at: create, updated_at: update)
end


maxUsersPerGroup.times do |i|
  create = Faker::Date.between(10.days.ago, Date.today)
  update = Faker::Date.between(create, Date.today)
  state = Faker::Address.state_abbr
  User.create(unique_name: Faker::Name.unique.name, password: "topkek", owner: false, age:50, state: state, created_at: create, updated_at: update)
end

# Generate categories
numCat = 20

numCat.times do |i|
  name = Faker::University.unique.name
  create = Faker::Date.between(10.days.ago, Date.today)
  update = Faker::Date.between(create, Date.today)
  offset = rand(offset) + 1
  desc = Faker::Hacker.say_something_smart
  Category.create(unique_name: name, user_id: offset, desc: desc, created_at: create, updated_at: update)
end

numProd = 100

numProd.times do |i|
  num = rand(10)
  if num >= 9
    name = Faker::Zelda.character + "_" + String(i)
  elsif num >= 6
    name = Faker::Pokemon.name + "_" + String(i)
  else
    name = Faker::Book.title + "_" + String(i)
  end
  cat_id = rand(numCat) + 1
  create = Faker::Date.between(10.days.ago, Date.today)
  update = Faker::Date.between(create, Date.today)
  sku = Faker::Number.unique.number(9)
  price = Faker::Number.decimal(2)
  Product.create(category_id: cat_id, unique_name: name, sku: sku, price: price, created_at: create, updated_at: update)
end

# Insert Purchases
=begin
numPurchases = 1000
# Random purchases
numPurchases.times do |i|
  user_id = rand(maxUsersPerGroup * 2) + 1
  product_id = rand(numProd) + 1
  quantity = rand(1000) + 1
  Purchase.create(user: user_id, product: product_id, quantity: quantity)
end

# Random correlation
numCorr = 5
corr_prod = []
# Generate user_id
numCorr.times do |i|
  corr_prod << rand(numProd) + 1
end
numCorr.times do |i|
  user_id = rand(maxUsersPerGroup * 2) + 1
  quantity = rand(100)
  numCorr.times do |d|
    Purchase.create(user: user_id, product: corr_prod[d], quantity: quantity)
  end
end

# Fixed correlated stuff.
numCorr = 100
corr_prod = 1
numCorr.times do |i|
  user_id = rand(maxUsersPerGroup * 2) + 1
  quantity = 10000
  numCorr.times do |d|
    Purchase.create(user: user_id, product: corr_prod, quantity: quantity)
    Purchase.create(user: user_id, product: corr_prod + 1, quantity: quantity)
  end
end
=end
