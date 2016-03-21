module FirstLogicTemplate

  class Tag < ActiveRecord::Base

    validates_presence_of :tag
    validates_presence_of :id

    include Enumerable

    def tags(id)
      self.where('id = ?',id)
    end

    def has_tag?(tbl,id,tag)
      tags(tbl,id).include?(tag)
    end

    def each(tbl,id,&block)
      tags(tbl,id).each(&block)
    end

  end

end

