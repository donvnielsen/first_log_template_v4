module FirstLogicTemplate

  class InstructionTag < ActiveRecord::Base
    belongs_to :instruction
    validates_presence_of :instruction_id
  end

end

