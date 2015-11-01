module FirstLogicTemplate

class Block < ActiveRecord::Base
  TEST_FOR_REPORT = /^Report:/i

  validates_presence_of :name
  attr_accessor :name
  attr_reader :seq_id
  attr_reader :instructions
  attr_reader :comments

  def Block.parse(i)
    raise ArgumentError,'nil block parameter is not permitted' if i.nil?

    case
      when (ii = /^begin +(?<type>[a-z0-9 .]+) *=*/i.match(i))
        return ['BEGIN',ii[:type].strip]
      when (/^END ?$/.match(i))
        return ['END',nil]
      else
        ii = i.split(/\.* *= */,2)
        return [ii[0].strip,ii[1].strip] if ii.size == 2
    end

    raise ArgumentError,"String could not be parsed as an instruction (#{i})"
  end

  # instructions are in an array, from BEGIN to END
  def initialize(instructions=nil)
    @name = nil
    pp instructions
    @instructions = instructions
    # parse_comments(instructions)
    parse_instructions
    self
  end

  private

  def parse_instructions
    raise ArgumentError,'instruction array is empty' if @instructions.nil? || @instructions.empty?
    raise ArgumentError,'First block instruction must be BEGIN' unless
        Instruction.parse(@instructions.first)[0] == 'BEGIN'
    raise ArgumentError,'Last block instruction must be END' unless
        Instruction.parse(@instructions.last)[0] == 'END'
    get_block_comments
    create_block
  end

  def get_block_comments

  end

  def create_block
    parm,@name = Instruction.parse(@instructions.first)
  end

  def get_block_instructions
  end
end

end