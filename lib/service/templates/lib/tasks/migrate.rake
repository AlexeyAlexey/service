namespace :db do
  desc 'Run migrations'
  task :migrate, [:version, :server_name] do |t, args|
    Sequel.extension :migration
    version = args[:version].to_i if args[:version]
    server_name = args[:server_name]

    db_migration_directory = ServiceApp.configuration[:db_migration_directory]

    if server_name.present?
      ::ServiceApp.db.with_server(server_name) do
        Sequel::Migrator.run(::ServiceApp.db, 'db/migrate', target: version, table: :schema_migrations)
      end
    else
      ::ServiceApp.db.servers.each do |server_name|
        ::ServiceApp.db.with_server(server_name) do
          Sequel::Migrator.run(::ServiceApp.db, 'db/migrate', target: version, table: :schema_migrations)
        end
      end
    end
  end

  namespace :generate do
    desc 'Genarate migrations'
    task :migration, [:name] do |t, args|
      version = DateTime.now.new_offset(0).strftime('%Y%m%d%H%M%S')

      db_migration_directory = ServiceApp.configuration[:db_migration_directory]

      migration_file = "#{db_migration_directory}/#{version}_#{args[:name]}.rb"

      File.open(migration_file, 'w') do |f|
        f.write <<~EOF
         Sequel.migration do
           up do
             run <<~SQL
             SQL
           end

           down do
             run <<~SQL
             SQL
           end
         end
        EOF
      end
    end
  end
end
