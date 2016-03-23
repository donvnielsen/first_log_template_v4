module FirstLogicTemplate

class Template < ActiveRecord::Base
  has_many :blocks,:dependent => :destroy
  include Enumerable

  validates :app_name,:app_id, presence: true
  before_save :set_create_date, on: :create

  # block iterator
  def each(&block)
    self.blocks.each(&block)
  end

  protected

  def set_create_date
    self.create_date = Time.now
  end
end

end