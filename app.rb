require 'sinatra'
require 'json'

# if Rack::Request.method_defined?(:host)
#   use Rack::HostAuthorization, []
# end

class HostAuthorization
  def initialize(app, allowed_hosts)
    @app = app
    @allowed_hosts = allowed_hosts
  end

  def call(env)
    request = Rack::Request.new(env)

    # Get host without port
    host_without_port = request.host.to_s

    # Debug output so you see what's happening
    puts "[DEBUG] Incoming Host header: #{host_without_port}"

    if @allowed_hosts.any? { |h| h === host_without_port }
      @app.call(env)
    else
      [403, { "Content-Type" => "text/plain" }, ["Blocked host: #{host_without_port}"]]
    end
  end
end

# Allow both production and dev hosts
use HostAuthorization, ['c.saint.bot', 'localhost', '127.0.0.1']

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
