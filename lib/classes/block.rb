module FirstLogicTemplate

class Block < ActiveRecord::Base
  belongs_to :template
  has_many :comments,:dependent => :destroy
  has_many :instructions,:dependent => :destroy
  has_many :block_tags,:dependent => :destroy

  include Enumerable

  TEST_FOR_REPORT = /^Report:/i

  before_validation :set_seq_id, on: [:create,:save]

  validates :template_id, :name, :seq_id, presence:  true
  validates_associated :template

  # after_save :store_instructions, on: :create
  # after_save :store_comments, on: :create

  # attr_reader :params
  # attr_accessor :template_id,:seq_id

  def Block.parse(instructions)
    raise ArgumentError,'instruction block must be an array' unless instructions.is_a?(Array)
    raise ArgumentError,'instruction array is empty' if instructions.nil? || instructions.empty?

    rc = {ii:instructions,cc:[],name:nil}

    while rc[:ii].first.length == 0 || [' ','*','#'].include?(rc[:ii].first[0,1])
      rc[:cc] << rc[:ii].shift
    end

    # ensure block begins with BEGIN, shift it out, then
    # pop off last instruction and make sure it is END
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
  # @param [Hash] options parameter options
  # @option options [Array] :block instruction block
  # @option options [Integer] :template_id required template id
  # @option options [Integer] :seq_id when inserting a new block
  def initialize(params,options={})
    @options = options
    super(params)
  end

  # def after_initialize
  #   @block = Block.parse(@options[:block])
  #   self.name = @block[:name]
  # end

  def instructions
    Instruction.where('block_id = ?',self.id).order(:seq_id)
  end

  def comments
    Comment.where('block_id = ?',self.id).order(:seq_id)
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
    self.comments.each{|c| bb << c.to_s }
    bb << sprintf('BEGIN %s',self.name)
    self.instructions.each{|i| bb << i.to_s}
    bb << 'END'
    bb.flatten
  end

  def to_s
    self.to_a.join("\n")
  end

  # === These process after saving. The block id is required prior
  #     to writing instructions and comments
  def store_instructions(ii)
    ii.each {|i| Instruction.create!(ins:i,block_id:self.id) }
  end

  def store_comments(cc)
    cc.each {|c| Comment.create!(text:c,block_id:self.id) }
  end

  protected

  # ==== these process prior to validations
  def set_seq_id
    max = Block.maximum(:seq_id) || 0
    @seq_id =
        case
          when @seq_id.nil? || max == 0 #append
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

  def set_seq_id
    max = Block.where('template_id = ?',self.template_id).maximum(:seq_id) || 0
    self.seq_id = case
                    when self.seq_id.nil? || max == 0
                      max += 1
                    when self.seq_id < 1 || self.seq_id > max
                      raise ArgumentError, "Specified location(#{self.seq_id}) is outside the range 1..#{max}"
                    else
                      bb = Block.
                          where( 'template_id = ? and seq_id >= ?',self.template_id,self.seq_id ).
                          order(:template_id,:seq_id)
                      bb.each {|b| b.update(seq_id:b.seq_id+1) }
                      self.seq_id
                  end

  end

end

end