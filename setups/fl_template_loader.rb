# gem 'first_logic_template'

require 'fl_template'

require 'optparse'
require 'singleton'
require 'pp'
pp $LOAD_PATH

module TemplateLoader
  OptionsStruct = Struct.new(:template,:db)

  class CmdLineOptions
    include Singleton

    @@args = OptionsStruct.new("NotSpecified")

    def self.args
      @@args
    end

    # This provides an easy way to dump the configuration as a hash
    def self.to_hash
      Hash[@@args.each_pair.to_a]
    end

    # Handles validating the configuration that has been loaded/configured
    def self.valid?
      raise ArgumentError,'Template file name is required' if CmdLineOptions.template.nil?
      raise ArgumentError,'Template file does not exist' unless FileTest.exist?(CmdLineOptions.template)
      raise ArgumentError,'Sqlite db file name is required' if CmdLineOptions.db.nil?
      true
    end

    # Pass any other calls (most likely attribute setters/getters on to the
    # configuration as a way to easily set/get attribute values
    def self.method_missing(method, *args, &block)
      if @@args.respond_to?(method)
        @@args.send(method, *args, &block)
      else
        raise NoMethodError
      end
    end

  end

  class CmdLineParser
    def self.parse(options)

      opt_parser = OptionParser.new do |opts|
        opts.banner = "Usage: example.rb [options]"
        opts.program_name = "ThisProgram"

        opts.on("-tFNAME", "--template=FNAME", "Template file name is required") {|o|
          CmdLineOptions.template = o
        }
        opts.on("-dFNAME", "--dbname=FNAME", "Sqlite db name is required") {|o|
          CmdLineOptions.db = o
        }
        opts.on("-h", "--help", "Prints this help") {
          puts opts
          exit
        }
        opts.on_tail("-v", "--version", "Show version information about this program and quit.") {
          puts "Option Parser Example v1.0.0"
          exit
        }
      end

      opt_parser.parse!(options)
    end
  end

  CmdLineParser.parse(ARGV)

  # setup db connection if options are valid
  if CmdLineOptions.valid?
    conn = ActiveRecord::Base.establish_connection(adapter:'sqlite3',database:CmdLineOptions.db)

    # create fl_template framework of tables if fl_templates table is not found
    unless ActiveRecord::Base.connection.tables.map(&:downcase).include?('fl_templates')
      FL_Template::DBDDL.each {|sql| conn.connection.execute(sql) unless sql.strip.size == 0 }
      conn.connection.execute('PRAGMA foreign_keys = on;')
    end

    # load the specified template in
    tmp = FL_Template::Template.create!(app_id:'flload',app_name:'Template Loader')
    tmp.import(CmdLineOptions.template)
    puts "Template #{CmdLineOptions.template} loaded with id(#{tmp.last.id})"
  end

end

