class Block
  attr_reader :name
  attr_reader :seq_id
  attr_reader :instructions
  attr_reader :comments

  def initialize(instructions)
    @instructions = []
    parse_instructions(instructions)
  end

  private

  def parse_instructions(instructions)

  end

  def get_block_name
    # find begin extract its value
  end

  def get_block_comments

  end

  def get_block_instructions

  end
end