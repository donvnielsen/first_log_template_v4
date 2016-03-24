module FirstLogicTemplate

class Block < ActiveRecord::Base
  belongs_to :template

  has_many :block_comments,:dependent => :destroy
  has_many :block_tags,:dependent => :destroy
  has_many :instructions,:dependent => :destroy

  include Enumerable

  TEST_FOR_REPORT = /^Report:/i

  after_initialize :after_init
  before_validation :set_seq_id, on: [:create,:save]

  validates :template_id, :name, :seq_id, presence:  true
  validate :check_template_exists, on: :create

  # after saving block to table, do these actions
  after_save :store_instructions, on: :create
  after_save :store_comments, on: :create

  after_destroy :update_seq_ids

  # attr_reader :params
  attr_accessor :block

  def Block.parse(o)
    raise ArgumentError,'instruction block must be an array' unless o.is_a?(Array)
    raise ArgumentError,'instruction array is empty' if o.nil? || o.empty?
    instructions = o.clone  # clone prevents manipulation of argument

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

  # save parameter from caller
  def block=(o)
    @block = Block.parse(o)
  end

  # instruction iterator
  def each(&block)
    self.instructions.each(&block)
    # Instruction.where('block_id = ?',self.id).each(&block)
  end

  # post initialize processing
  def after_init
    if new_record?
      self.name = @block[:name] unless self.block.nil?
    end
  end

  # block instructions in seq_id order
  # def instructions
  #   Instruction.where('block_id = ?',self.id).order(:seq_id)
  # end

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
    self.block_comments.each{|c| bb << c.to_s }
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
  def store_instructions
    @block[:ii].each {|i|
      Instruction.create!(ins:i,block_id:self.id)
    } unless @block.nil?
  end

  def store_comments
    @block[:cc].each {|c| BlockComment.create!(text:c, block_id:self.id) } unless @block.nil?
  end

  def update_seq_ids(i=0)
    Block.where('template_id = ?',self.template_id).order(seq_id: :asc).each {|b|
      b.update(seq_id: (i+=1))
    }
  end

  def tagged?(tags)
    case
      when tags.is_a?(Array)
        self.block_tags.collect {|bt| return true if tags.include?(bt.tag) }
      else
        self.block_tags.collect {|bt| return true if bt.tag == tags }
    end
    false
  end

  def add_tag(tag)
    begin
      BlockTag.create!(block_id: self.id,tag: tag) unless tagged?(tag)
    rescue ActiveRecord::RecordNotUnique
    end
  end

  def remove_tag(tag)
    tt = case
           when tag == :all
             BlockTag.where('block_id = ?',self.id)
           else
             BlockTag.where('block_id = ? and tag = ?',self.id,tag)
         end
    raise ArgumentError,"Tag '#{tag}' not applied to block" if tag != :all && tt.count == 0
    tt.each {|tag| tag.destroy}
  end

  protected

  # ==== these process prior to validations

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

  # ensures template exists before saving block
  def check_template_exists
    Template.find(self.template_id) unless self.template_id.nil?
  end

end

end