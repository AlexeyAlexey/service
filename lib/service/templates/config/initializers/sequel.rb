

ServiceApp.load_config_file('database', ServiceApp.root)

ServiceApp.configure do |conf|
  conf.db_migration_directory = "#{ServiceApp.root}/db/migrate"
end


# https://github.com/jeremyevans/sequel/blob/master/lib/sequel/database/logging.rb#L81
module Sequel
  class Database
    # Log message with message prefixed by duration at info level, or
    # warn level if duration is greater than log_warn_duration.
    def log_duration(duration, message)
      return if sql_log_level == :error
      log_each((lwd = log_warn_duration and duration >= lwd) ? :warn : sql_log_level, "(#{sprintf('%0.6fs', duration)}) #{message}")
    end
  end
end


# Sequel.extension :migration
Sequel.default_timezone = :utc
Sequel.datetime_class = DateTime
Sequel.extension :core_extensions


default_server = ServiceApp.configuration.database[ServiceApp.env].merge({ logger: ServiceApp.logger })
::ServiceApp.db_connection = Sequel.connect(default_server)

# DB = Sequel.connect(default_server)


# Primary/Replica Configurations and Database Sharding
# https://github.com/jeremyevans/sequel/blob/master/doc/sharding.rdoc
# servers = ServiceApp.configuration.database[ServiceApp.env]
# ::ServiceApp.db_connection = Sequel.connect(default_server, servers: servers)


::ServiceApp.db.sql_log_level = :error # :info :error
::ServiceApp.db.log_warn_duration = 0.5

::ServiceApp.db.extension :pg_json
::ServiceApp.db.extension :pg_array
::ServiceApp.db.extension :server_block
::ServiceApp.db.extension :server_logging

# Fork Safety
# http://sequel.jeremyevans.net/rdoc/files/doc/fork_safety_rdoc.html
# ::ServiceApp.db_connection.disconnect
#   Sequel::DATABASES.each(&:disconnect)

# If you use Primary/Replica Configurations and Database Sharding
# ::ServiceApp.db.servers.each do |server_name|
#   ::ServiceApp.db.with_server(server_name) do
#     ::ServiceApp.db.test_connection

#     ServiceApp.logger.info "DB was connected DB name is #{server_name} " \
#       "DB current time is #{::ServiceApp.db["SELECT NOW();"].first.inspect}"
#   end
# end

# You can use the following interface to do a db query
# ::ServiceApp.db

# ServiceApp.db["SELECT table_name FROM information_schema.tables WHERE table_schema='public'"].all
# ServiceApp.db["SELECT session_user, current_database();"].all
