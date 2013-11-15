require 'que'

Dir["./spec/support/**/*.rb"].sort.each &method(:require)

QUE_URL = ENV["DATABASE_URL"] || "postgres://postgres:@localhost/que-test"

# We use Sequel to introspect the database in specs.
require 'sequel'

DB = Sequel.connect(QUE_URL)
DB.drop_table? :que_jobs
DB.run Que::CreateTableSQL

RSpec.configure do |config|
  config.before do
    DB[:que_jobs].delete
    $logger.messages.clear
  end
end

# Set up a dummy logger.
$logger = Object.new

def $logger.messages
  @messages ||= []
end

def $logger.method_missing(m, message)
  messages << message
end

Que.logger = $logger
