require 'sqlite3'

class Db
  SCRIPTS_FOLDER = File.join(Dir.getwd,'db','sql')

  attr_reader :fname
  attr_reader :db

  def initialize(fname=':memory:')
    @fname = fname
    build_db
  end

  def append_block(name)
    @db.execute( "INSERT INTO blocks (name, seq_id) values (?,(select ifnull(max(seq_id)+1,1) from blocks))",name)
  end

  def insert_block(name,loc,seq)
    raise ArgumentError,'Block loc must be :before or :after' unless [:before,:after].include?(loc)
    seq += 1 if loc == :after
    @db.execute("update blocks set seq_id = seq_id+1 where seq_id >= ?",seq)
    @db.execute( "INSERT INTO blocks (name, seq_id) values (?,?)",name,seq)
  end

  def delete_block(seq_id)
    pp @db.execute('select * from instructions')

    @db.execute( "DELETE FROM blocks WHERE seq_id = ?",seq_id)
  end

  def find_blocks(name)
    @db.execute("select * from blocks where name = '?'",name)
  end

  def append_block_comment(block_id,comment)
    @db.execute(
"INSERT INTO block_comments (ln, block_id,seq_id)
values (?,?,(select ifnull(max(seq_id)+1,1) from block_comments where block_id = ?) ) ",
      comment,
      block_id,
      block_id
    )
  end

  def append_instruction(block_id,parm,arg)
    @db.execute(
        "INSERT INTO instructions (parm,arg,block_id,seq_id)
values (?,?,?,(select ifnull(max(seq_id)+1,1) from block_comments where block_id = ?) )",
        parm,
        arg,
        block_id,
        block_id
    )
  end
  def insert_instruction(block_id,parm,arg,loc,seq)
    case loc
      when :before
      when :after
        seq += 1
      else
        raise ArgumentError,'Instruction loc must be :before or :after'
    end
    begin
      @db.execute("update instructions set seq_id = seq_id+1 where block_id = ? and seq_id >= ?",block_id,seq)
      @db.execute( "INSERT INTO instructions (block_id,parm,arg,seq_id) values (?,?,?,?)",block_id,parm,arg,seq)
    rescue SQLite3::ConstraintException
      puts block_id,parm,arg,loc,seq
      raise
    # else
    #   raise
    end

  end
  def delete_instruction(block_id,seq)
    @db.execute("DELETE FROM instructions where block_id = ? and seq_id = ?",block_id,seq)
  end
  def find_instructions

  end
  def export

  end

  private

  def build_db
    @db = SQLite3::Database.new(self.fname)
    [
        'db_setup.sql',
        'create_blocks_table.sql',
        'create_instructions_table.sql',
        'create_block_comments_table.sql'
    ].each {|sql|
      @db.execute File.readlines(File.join(SCRIPTS_FOLDER,sql)).join(' ')
    }
  end

end