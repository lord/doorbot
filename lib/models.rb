require 'active_record'
ActiveRecord::Base.establish_connection('sqlite3://development.db')

class User < ActiveRecord::Base
end
