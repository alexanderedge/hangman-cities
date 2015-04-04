source 'https://rubygems.org'
gem 'sinatra'
gem 'json'
gem 'data_mapper'
gem 'dm-timestamps'

# local development uses SQLite
group :development do
  gem 'dm-sqlite-adapter'
end

# Heroku uses postgres
group :production do
  gem 'dm-postgres-adapter'
end
