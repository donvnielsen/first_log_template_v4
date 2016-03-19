module FirstLogicTemplate

class Template < ActiveRecord::Base
  has_many :blocks,:dependent => :destroy
  include Enumerable

  validates :app_name,:app_id, presence: true

  # block iterator
  def each(&block)
    Block.where('template_id = ?',self.id).order(seq_id: :asc).each(&block)
  end

end

end