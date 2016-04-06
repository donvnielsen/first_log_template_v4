module FirstLogicTemplate

  class BlockTag < ActiveRecord::Base
    self.table_name = 'fl_block_tags'
    belongs_to :block

    validates_presence_of :tag
    validates_presence_of :block_id

    def tags(block_id)
      self.where('block_id = ?',block_id)
    end

    def tagged?(block_id,tag)
      self.tags(block_id).include?(tag)
    end

  end

end

