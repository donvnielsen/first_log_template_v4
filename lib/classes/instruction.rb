module FirstLogicTemplate

class Instruction < ActiveRecord::Base
  TEST_FOR_FNAME = /(directory|file name|path|filename)/i

  before_validation :fname_transformations
  before_validation :set_seq_id, on: [:create,:save]

  validates_presence_of :parm
  validates_presence_of :block_id
  validates_presence_of :seq_id, on: :update

  # attr_accessor :block_id,:parm,:arg,:seq_id,:is_fname

  # delete_all requires an array in the form [sql,block_id,...]
  # the array is passed on thru super
  # then block_id is used to resequence the seq_id
  def Instruction.delete_all(ary)
    x = super(ary)
    ii = Instruction.where( 'block_id = ?',ary[1]).order(:seq_id)
    ii.each_with_index {|i,j| i.update(seq_id:j+1) }
    x  # the number of deleted rows must be returned
  end

  def Instruction.arg_loc=(o)
    raise ArgumentError,"Arg location value must be numeric #{o}" if /\D/.match(o.to_s)
    @@arg_loc = o.to_i
  end
  def Instruction.arg_loc
    @@arg_loc ||=45
  end

  # Split the instruction line into parameter and argument, returning
  # result as an array [parm,arg].
  # @param [String] String, in the format 'parm... = arg', to be parsed
  # @return [Array] [parm,arg]
  def Instruction.parse(i)
    raise ArgumentError,'nil instruction parameter is not permitted' if i.nil?

    case
      when (ii = /^begin +(?<type>[a-z0-9 .:,()\/%]+) *=*/i.match(i))
        return ['BEGIN',ii[:type].strip]
      when (/^END ?$/.match(i))
        return ['END',nil]
      else
        ii = i.split(/\.* *= */,2)
        return [ii[0].strip,ii[1].strip] if ii.size == 2
    end

    raise ArgumentError,"String could not be parsed as an instruction (#{i})"
  end

  def Instruction.has_fname?(o)
    !TEST_FOR_FNAME.match(o).nil?
  end

  def Instruction.pop_i(block_id,j=1)
    raise ArgumentError,'# to pop must be an integer' unless j.is_a?(Integer)
    raise ArgumentError,'# to pop larger than number of instructions' if
      j > Instruction.where('block_id = ?',block_id).count
    ii = Instruction.
      select(:id,:block_id,:seq_id).
      where('block_id = ?',block_id).
      order(seq_id: :desc).
      limit(j)
    rtrn = []
    ii.each {|i|
      rtrn.unshift(i)
      Instruction.delete(i.id)
    }
    rtrn
  end

  # @param [Hash] params parameter options
  # @option params [String] :parm instruction parm (when not using :ins)
  # @option params [String] :arg instruction arg (when not using :ins)
  # @option params [String] :ins instruction string (when not using :parm & :arg)
  # @option params [Integer] :block_id required parent block id
  # @option params [Integer] :seq_id when inserting a new instruction
  def initialize(params)
    @params  = params
    raise ArgumentError,'Block_id is required' unless @params.has_key?(:block_id) && !@params[:block_id].nil?
    raise ArgumentError,'Block_id not found' if Block.find(@params[:block_id]).nil?
    if @params.has_key?(:ins)
      raise ArgumentError,'parm: & arg: not permitted when ins: specified' if
          @params.has_key?(:parm) || @params.has_key?(:arg)
      @parm,@arg = Instruction.parse(@params[:ins])
    else
      raise ArgumentError,'parm: & arg: are required together when ins: not specified' unless
          @params.has_key?(:parm) && @params.has_key?(:arg)
      @parm = @params[:parm]
      @arg = @params[:arg]
    end

    @block_id = @params[:block_id]
    @seq_id = @params[:seq_id] if @params.has_key?(:seq_id)

    super(block_id:@block_id,parm:@parm,arg:@arg)
  end

  def to_a
    [self.parm,self.arg]
  end

  def to_h
    {parm:self.parm,arg:self.arg}
  end

  def to_s
    p = Instruction.arg_loc-self.parm.length	    # calculate number of periods to insert
    sprintf('%s%s = %s',self.parm,'.'*(p < 0 ? 0 : p),self.arg.nil? ? '' : self.arg)
  end

  protected

  # note to self.  don't mess with self vs @ in this routine.
  def fname_transformations
    self.is_fname = !TEST_FOR_FNAME.match(self.parm).nil?
    self.arg = @arg.gsub('\\', '/') unless @arg.nil? || !self.is_fname
  end

  def set_seq_id
    max = Instruction.where('block_id = ?',self.block_id).maximum(:seq_id) || 0
    self.seq_id = case
                when @seq_id.nil?
                  max += 1
                when @seq_id < 1 || @seq_id > max
                  raise ArgumentError, "Specified location(#{@seq_id}) is outside the range 1..#{max}"
                else
                  ii = Instruction.
                      where( 'block_id = ? and seq_id >= ?',@block_id,@seq_id ).
                      order(:block_id,:seq_id)
                  ii.each {|i| i.update(seq_id:i.seq_id+1) }
                  @seq_id
              end

  end

end

end
