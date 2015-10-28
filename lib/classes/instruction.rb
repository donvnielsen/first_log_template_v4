class Instruction

  attr_reader :parm
  attr_accessor :arg

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
  # @return [Hash] {KeyTypes=>String,ValueTypes=>String}
  def Instruction.parse(i)
    raise ArgumentError,'nil instruction parameter is not permitted' if i.nil?

    case
      when (ii = /^begin +(?<type>[a-z0-9 .]+) *=*/i.match(i))
        return {parm:'BEGIN',arg:ii[:type].strip}
      when (/^END ?$/.match(i))
        return {parm:'END',arg:nil}
      else
        ii = i.split(/\.* *= */,2)
        return {parm:ii[0].strip,arg:ii[1].strip} if ii.size == 2
    end

    raise ArgumentError,"String could not be parsed as an instruction (#{i})"
  end

  def arg=(o)
    m = /(directory|file|path)/i.match(self.parm)
    @arg = m.nil? ? o : o.gsub('\\','/')
  end

  # @params String
  def initialize(params)

    case
      when params.is_a?(String)
        i = Instruction.parse(params)
        @parm = i[:parm]
        self.arg = i[:arg]
      when params.is_a?(Hash)
        raise ArgumentError, 'Instruction hash must have :parm & :arg keys' unless
            params.has_key?(:parm) && params.has_key?(:arg)
        @parm = params[:parm]
        self.arg = params[:arg]
      when params.nil?
        raise ArgumentError, 'Parm,Arg must be provided to instruction'
      else
        raise ArgumentError, "Only String and Hash classes accepted"
    end
  end

  def to_a
    [self.parm,self.arg]
  end

  def to_h
    {parm:self.parm,arg:self.arg}
  end

  def to_s
    p = @@arg_loc-self.parm.length		# calculate number of periods to insert
    i = self.parm+'.'*(p < 0 ? 0 : p)+' = '		    # construct parm of instruction
    i += self.arg.to_s if self.arg	# append argument if argument available
    i				                        # return rebuilt instruction
  end

end