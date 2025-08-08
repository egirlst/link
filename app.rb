require 'sinatra'
require 'json'

# Configure Sinatra to bind to all interfaces and port 3099
set :bind, '0.0.0.0'
set :port, 3099

# Add debugging middleware to see what host header we're getting
use Rack::CommonLogger
before do
  puts "Host header: #{request.host}"
  puts "All headers: #{request.env.select { |k,v| k.start_with?('HTTP_') }}"
end

# Temporarily disable host authorization to debug
set :protection, except: [:host_authorization]

PASSWORD = 'ghjk'
DATA_FILE = 'shortcuts.json'

def load_shortcuts
  if File.exist?(DATA_FILE)
    JSON.parse(File.read(DATA_FILE))
  else
    {}
  end
end

def save_shortcuts(shortcuts)
  File.write(DATA_FILE, JSON.pretty_generate(shortcuts))
end

SHORTCUTS = load_shortcuts

# Temporary test route
get '/' do
  "URL Shortener is working! Host: #{request.host}"
end

post '/create' do
  return status 401 unless params['password'] == PASSWORD
  name = params['name']
  link = params['link']
  halt 400, "Missing name or link" unless name && link
  SHORTCUTS[name] = link
  save_shortcuts(SHORTCUTS)
  "Shortcut '#{name}' created."
end

get '/:name' do
  link = SHORTCUTS[params['name']]
  return status 404 unless link
  redirect link
end

# Server will start automatically with Puma
