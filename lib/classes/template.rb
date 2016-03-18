module FirstLogicTemplate

class Template < ActiveRecord::Base
  has_many :blocks,:dependent => :destroy
  include Enumerable

  validates_presence_of :app_name
  validates_presence_of :app_id

  def initialize(o)
    raise ArgumentError if o.nil?
    raise ArgumentError unless o.has_key?(:app_id)
    raise ArgumentError unless o.has_key?(:app_name)

    @params = o
    @app_id = @params[:app_id]
    @app_name = @params[:app_name]

    super(app_id:@app_id,app_name:@app_name)
  end

  def append_block(blk)

  end
end

end