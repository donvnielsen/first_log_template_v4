module FirstLogicTemplate

class Instruction < ActiveRecord::Base
  TEST_FOR_FNAME = /(directory|file name|path|filename)/i

  validates_presence_of :parm
  validates_presence_of :block_id

  before_validation :set_seq_id, on: [:create,:save]
  before_validation :fname_transformations

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

  # @param [Hash] params parameter options
  # @option params [String] :ins instruction string in the format parm... = arg
  # @option params [Integer] :at location at which an insert is to placed
  def initialize(params)
    @params = params.is_a?(Hash) ? params : {}

    if @params.has_key?(:ins)
      @params[:parm],@params[:arg] = Instruction.parse(@params[:ins])
    end

    super(@params.except(:at,:ins))
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

  def to_a
    [self.parm,self.arg]
  end

  def to_h
    {parm:self.parm,arg:self.arg}
  end

  def to_s
    p = Instruction.arg_loc-self.parm.length	    # calculate number of periods to insert
    i = self.parm+'.'*(p < 0 ? 0 : p)+' = '		    # construct parm of instruction
    i += self.arg.to_s if self.arg	              # append argument if argument available
    i				                                      # return rebuilt instruction
  end

  def is_fname?
    self.is_fname
  end

  protected

  def fname_transformations
    if TEST_FOR_FNAME.match(self.parm)
      self.is_fname = 1
      self.arg = self.arg.gsub('\\', '/') unless self.arg.nil?
    end
  end

  def set_seq_id
    max = Instruction.where('block_id = ?',self.block_id).maximum(:seq_id) || 0
    self.seq_id = case
      when !@params.has_key?(:at) #append
        max += 1
      when @params[:at] < 1 || @params[:at] > max
        raise ArgumentError, "Specified :at(#{@params[:at]}) is outside the range 1..#{max}"
      else
#         sql = <<eos
# update #{Instruction.table_name}
# set seq_id = seq_id + 1
# where block_id = #{self.block_id} and seq_id >= #{@params[:at]}
# eos
#         ActiveRecord::Base.connection.execute(sql)
        # pp Instruction.where( 'block_id = ? and seq_id >= ?',self.block_id,@params[:at] ).to_sql
        ii = Instruction.
            where( 'block_id = ? and seq_id >= ?',self.block_id,@params[:at] ).
            order(:block_id,:seq_id)
        ii.each {|i| i.update(seq_id:i.seq_id+1) }
        @params[:at]
    end
  end

end

end