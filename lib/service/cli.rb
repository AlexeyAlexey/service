# frozen_string_literal: true

module Service
  class CLI < Thor
    include Thor::Actions

    desc 'new', 'Creating new service'
    method_options :activerecord => :boolean, :alias => :string
    method_options :sequel => :boolean, :alias => :string
    method_options :sidekiq => :boolean, :alias => :string
    method_options :sidekiq_cron => :boolean, :alias => :string

    def new(service_name)
      destination = service_name

      directory('service', destination, mode: :preserve)

      if options.activerecord?
        # directory('config/initializers', destination, mode: :preserve)
        copy_file 'config/initializers/active_record.rb', "#{destination}/config/initializers/active_record.rb"
        copy_file 'lib/tasks/import_active_record_tasks.rb', "#{destination}/lib/tasks/import_active_record_tasks.rb"
      elsif options.sequel?
        copy_file 'config/initializers/sequel.rb', "#{destination}/config/initializers/sequel.rb"
        copy_file 'lib/tasks/migrate.rake', "#{destination}/lib/tasks/migrate.rake"
      end

      if options.activerecord? || options.sequel?
        copy_file 'config/database.yml', "#{destination}/config/database.yml"
      end

      if options.sidekiq? || options.sidekiq_cron?
        copy_file 'config/initializers/sidekiq.rb', "#{destination}/config/initializers/sidekiq.rb"

        if options.sidekiq_cron?
          copy_file 'config/initializers/sidekiq_cron.rb', "#{destination}/config/initializers/sidekiq_cron.rb"
          copy_file 'app/jobs/hard_worker.rb', "#{destination}/app/jobs/hard_worker.rb"
        end
      end
    end
  end
end
