require 'sinatra'
require 'json'

# Configure Sinatra to bind to all interfaces and port 3099
set :bind, '0.0.0.0'
set :port, 3099

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
