require 'sinatra/activerecord' 
# require 'bundler/setup'
# Bundler.require

# ActiveRecord::Base.establish_connection

class User < ActiveRecord::Base
  has_many :calendars
  has_many :logos
  validates :mail, uniqueness: true
end

class Calendar < ActiveRecord::Base
  belongs_to :user
end

class Logo < ActiveRecord::Base
  belongs_to :user
end