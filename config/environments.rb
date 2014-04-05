class DoorbotApp
  configure :development, :test, :production do
    set :database, 'sqlite:///development.db'
  end
end