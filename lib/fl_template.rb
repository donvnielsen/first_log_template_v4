require 'active_record'

require_relative '../lib/ext/fl_regex'
require_relative '../lib/classes/template'
require_relative '../lib/classes/block'
require_relative '../lib/classes/instruction'
require_relative '../lib/classes/block_comment'

require_relative '../lib/classes/block_tag'
require_relative '../lib/classes/instruction_tag'

require 'progressbar'

module FL_Template
  ROOTDIR = __dir__
  # because sqlite cannot handle multiple statements in one file, each
  # statement is split (using ;) into an array of statements, where
  # the array should be iterated over and each submitted separately.
  DBDDL = File.read(
      File.join(FL_Template::ROOTDIR,'sql','db_ddl.sql')
  ).split(';').map{|sql| sql.strip.nil? ? nil : sql.strip<<';'}
end