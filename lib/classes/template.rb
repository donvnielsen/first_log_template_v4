module FirstLogicTemplate

class Template < ActiveRecord::Base
  has_many :blocks,:dependent => :destroy
  include Enumerable

  validates :app_name,:app_id, presence: true

end

end