module FirstLogicTemplate

  class InstructionTag < ActiveRecord::Base
    self.table_name = 'fl_instruction_tags'
    belongs_to :instruction

    validates_presence_of :instruction_id
  end

end

