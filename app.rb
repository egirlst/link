require 'sinatra'
require 'json'

# Disable Rack Host Authorization entirely
if Rack::Request.method_defined?(:host)
  use Rack::HostAuthorization, []  # Empty list allows all hosts
end

set :bind, '0.0.0.0'
set :port, 3099

PASSWORD = 'ghjk'
DATA_FILE = 'shortcuts.json'

def load_shortcuts
  File.exist?(DATA_FILE) ? JSON.parse(File.read(DATA_FILE)) : {}
end

def save_shortcuts(shortcuts)
  File.write(DATA_FILE, JSON.pretty_generate(shortcuts))
end

SHORTCUTS = load_shortcuts

get '/' do
  "URL Shortener is working! Host: #{request.host}"
end

post '/create' do
  halt 401 unless params['password'] == PASSWORD
  name, link = params.values_at('name', 'link')
  halt 400, "Missing name or link" unless name && link
  SHORTCUTS[name] = link
  save_shortcuts(SHORTCUTS)
  "Shortcut '#{name}' created."
end

get '/:name' do
  link = SHORTCUTS[params['name']]
  halt 404 unless link
  redirect link
end
