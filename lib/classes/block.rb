module FirstLogicTemplate

class Block < ActiveRecord::Base
  attr_accessor :name
  attr_reader :seq_id
  attr_reader :instructions
  attr_reader :comments

  def initialize(name=nil,instructions=nil)
    @name = name
    parse_instructions(instructions) unless instructions.nil?
    self
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

end