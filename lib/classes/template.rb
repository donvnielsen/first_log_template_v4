# data base is from a parent application
# template does not create one
# template requires an existing connection
class Template
  attr_reader :fname
  attr_reader :db
  def initialize
    @db = Db.new
  end

  def import(fname)
    block_parms = {name:nil,comments:[],instructions:[]}
    i_begin = false
    File.readlines(fname).each {|i|
      i.strip!
      case
        when (m=/^#(?<comment>.+)/i.match(i))
          raise RuntimeError,'Intra block comments are not permitted' if i_begin
          m[:comment].strip!
          block_parms[:comments] << m[:comment] if m[:comment].size > 0
        when (m=/^begin (?<name>[a-z0-9. \#+]+)/i.match(i))
          raise RuntimeError,"Template error: BEGIN #{self.name} is not followed by an END" if i_begin
          i_begin = true
          block_parms[:name] = m[:name]
        when /^end.+/i.match(i)
          self.db.block_append(block_parms.name)
          Block.append(@db.db)
          # commit block
          # commit instructions
          # commit comments
          i_begin = false
        else
          block_parms[:@ii] << i
      end
    }
  end

  def block_append(b)
    @db.db.execute( "INSERT INTO blocks (name, seq_id) values (?,select max(seq_id)+1 from blocks",b.parm)
  end

  def parse_instructions(instructions)
    i_begin = false

    instructions.each {|i|
      case
        when (m=/^#(?<comment>.+)/i.match(i.strip))
          rtrn[:comments] << m[:comment].strip
        when (m=/^begin (?<name>[a-z0-9. \#+]+)/i.match(i.strip))
          raise RuntimeError,"Template error: BEGIN #{self.name} is not followed by an END" if i_begin
          i_begin = true
          rtrn[:name] = m[:name]
        when (m=/^end.+/i.match(i.strip))
          break
        else
          rtrn[:@ii] << i
      end
    }

    rtrn
  end

end