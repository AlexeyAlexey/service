require 'active_record'

ActiveRecord::Base.configurations = ServiceApp.config.database.to_h.stringify_keys

ActiveRecord::Base.establish_connection(ServiceApp.env.to_sym)

ActiveRecord::Base.logger = ServiceApp.logger
