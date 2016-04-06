require 'rspec'
require 'simplecov'
# SimpleCov.start

require 'active_record'
require 'active_record/migration'

require_relative '../lib/ext/fl_regex'
require_relative '../lib/classes/template'
require_relative '../lib/classes/block'
require_relative '../lib/classes/instruction'
require_relative '../lib/classes/block_comment'

require_relative '../lib/classes/block_tag'
require_relative '../lib/classes/instruction_tag'

require 'pp'

module FL_Template
  DB_NAME = 'db/test_template.db'
  DDL_NAME = 'lib/sql/db_ddl.sql'
  # MIGRATIONS = 'lib/migrations'

  File.delete(DB_NAME) if File.exist?(DB_NAME)

  conn = ActiveRecord::Base.establish_connection(adapter:'sqlite3',database:DB_NAME)
  sqls = File.read(DDL_NAME).split(';')
  sqls.each {|sql| conn.connection.execute(sql<<';') unless sql.strip.size == 0 }
  conn.connection.execute('PRAGMA foreign_keys = on;')

  # ActiveRecord::Migrator.migrate MIGRATIONS,VERSION=0
  # ActiveRecord::Migrator.migrate MIGRATIONS
end

