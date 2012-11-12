Rails.application.config.middleware.use Rack::Auth::Basic, "Restricted Area" do |username, password|
  [username, password] == ['echannel', 'echan5000']
end
