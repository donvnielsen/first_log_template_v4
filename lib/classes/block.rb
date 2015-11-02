module FirstLogicTemplate

class Block < ActiveRecord::Base
  TEST_FOR_REPORT = /^Report:/i

  validates_presence_of :name
  validates_presence_of :seq_id

  before_validation :set_seq_id, on: [:create,:save]

  after_create :store_instructions, on: [:create,:save]
  after_create :store_comments, on: [:create,:save]

  # instructions are in an array, from BEGIN to END
  def initialize(params)
    @params = params.is_a?(Hash) ? params : {}
    @ii = @params[:block]
    @cc = []
    @name = nil
    parse_instructions
    super(name:@name,seq_id:@seq_id,is_report:false,contains_fname:false)
  end

  def instructions
    ii = []
    Instruction.where('block_id = ?',self.id).order(:seq_id).each{|i| ii << i.to_s }
    ii
  end

  def comments
    cc = []
    Comment.where('block_id = ?',self.id).order(:seq_id).each{|c| cc << c.text}
    cc
  end

  protected

  def parse_instructions
    raise ArgumentError,'instruction array is empty' if @ii.nil? || @ii.empty?

    while @ii.first.length == 0 || [' ','*','#'].include?(@ii.first[0,1])
      @cc << @ii.shift
    end

    raise ArgumentError,'First block instruction must be BEGIN' unless
        Instruction.parse(@ii.first)[0] == 'BEGIN'
    parm,@name = Instruction.parse(@ii.shift)

    raise ArgumentError,'Last block instruction must be END' unless
        Instruction.parse(@ii.last)[0] == 'END'
    @ii.pop

  end

  def store_instructions
    @ii.each {|i| Instruction.create(ins:i,block_id:self.id) }
  end

  def store_comments
    @cc.each {|c| Comment.create(text:c,block_id:self.id) }
  end

  def set_seq_id
    max = Block.maximum(:seq_id) || 0
    self.seq_id =
        case
          when !@params.has_key?(:at) #append
            max += 1
          when @params[:at] < 1 || @params[:at] > max
            raise ArgumentError, "Specified :at(#{@params[:at]}) is outside the range 1..#{max}"
          else
            bb = Block.where( 'seq_id >= ?',@params[:at] ).order(:seq_id)
            bb.each {|b| b.update(seq_id:b.seq_id+1) }
            @params[:at]
        end
  end

end

end