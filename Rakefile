%w[rubygems dm-core dm-migrations].each { |r| require r }


desc 'Migrates the database'
task :migrate do
    DataMapper.auto_migrate!
end
