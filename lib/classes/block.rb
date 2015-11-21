module FirstLogicTemplate

class Block < ActiveRecord::Base
  include Enumerable

  TEST_FOR_REPORT = /^Report:/i

  # before_validation :set_seq_id, on: [:create,:save]
  # before_validation :set_is_report
  # before_validation :set_has_fname

  validates_presence_of :name
  validates_presence_of :seq_id

  after_save :store_instructions, on: :create
  after_save :store_comments, on: :create

  attr_reader :params

  def Block.parse(blk)
    raise ArgumentError,'instruction block must be an array' unless blk.is_a?(Array)
    raise ArgumentError,'instruction array is empty' if blk.nil? || blk.empty?

    rc = {ii:blk,cc:[],name:nil}

    while rc[:ii].first.length == 0 || [' ','*','#'].include?(rc[:ii].first[0,1])
      rc[:cc] << rc[:ii].shift
    end

    raise ArgumentError,'First block instruction must be BEGIN' unless
        Instruction.parse(rc[:ii].first)[0] == 'BEGIN'
    p,rc[:name] = Instruction.parse(rc[:ii].shift)

    raise ArgumentError,'Last block instruction must be END' unless
        Instruction.parse(rc[:ii].pop)[0] == 'END'

    rc
  end


  # instruction iterator
  def each(&block)
    Instruction.where('block_id = ?',self.id).each(&block)
  end

  # instructions are in an array, from BEGIN to END
  def initialize(o)

    raise ArgumentError,'Block must receive an array' unless o.is_a?(Hash)
    raise ArgumentError,'ins: is required' unless o.has_key?(:ins)
    raise ArgumentError,'ins: must specify an array of instructions' unless o[:ins].is_a?(Array)

    @params = Block.parse(o[:ins])
    @name = @params[:name]
    set_seq_id
    set_is_report
    set_has_fname

    super(name:@name,seq_id:@seq_id,is_report:@is_report,has_fname:@has_fname)
  end

  def instructions
    ii = []
    j = Instruction.where('block_id = ?',self.id).order(:seq_id)
    j.each {|i| ii << i.to_s }
    ii
  end

  def comments
    cc = []
    Comment.where('block_id = ?',self.id).order(:seq_id).each{|c| cc << c.text}
    cc
  end

  def file_names
    ff = []
    Instruction.
        where('block_id = ? and is_fname = ?',self.id,true).
        each{|fname| ff << fname.arg }
    ff
  end

  def is_report?
    @is_report
  end

  def has_fname?
    @has_fname
  end

  # regexp find of matching instruction parms in block
  def find_all_i(o=/.*/)
    raise ArgumentError,'search criteria must be expressed as a regular expression' unless o.is_a?(Regexp)
    ary=[]
    self.each {|i| ary << i if o.match(i.parm)}
    ary
  end

  def to_a
    bb = []
    bb << comments
    bb << sprintf('BEGIN %s',self.name)
    instructions.each{|i| bb << i.to_s}
    bb << 'END'
    bb.flatten
  end

  def to_s
    self.to_a.join("\n")
  end

  protected

  # ==== these process prior to validations
  def set_seq_id
    max = Block.maximum(:seq_id) || 0
    @seq_id =
        case
          when @seq_id.nil? #append
            max + 1
          when @seq_id < 1 || @seq_id > max
            raise ArgumentError, "Specified :at(#{@seq_id}) is outside the range 1..#{max}"
          else
            bb = Block.where( 'seq_id >= ?',@seq_id ).order(:seq_id)
            bb.each {|b| b.update(seq_id:b.seq_id+1) }
            @seq_id
        end
  end


  # identifies if block is report block
  def set_is_report
    @is_report = !TEST_FOR_REPORT.match(@name).nil?
  end

  # identifies if any instruction parm indicates a file name
  def set_has_fname
    @params[:ii].each {|parm,arg|
      @has_fname = Instruction.has_fname?(parm)
      break if @has_fname
    }
    @has_fname
  end

  # === These process after saving. The block id is required prior
  #     to writing instructions and comments
  def store_instructions
    @params[:ii].each {|i| Instruction.create!(ins:i,block_id:self.id) }
  end

  def store_comments
    @params[:cc].each {|c| Comment.create(text:c,block_id:self.id) }
  end
end

end