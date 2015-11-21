module FirstLogicTemplate

  class Comment < ActiveRecord::Base
  validates_presence_of :block_id
  # validates_presence_of :text

  before_validation :set_seq_id, on: [:create,:save]

  # @param [Hash] params parameter options
  # @option params [String] :text comment text
  # @option params [Integer] :block_id parent block
  # @option params [Integer] :at location at which an insert is to placed
  def initialize(params)
    @params = params.is_a?(Hash) ? params : {}

    super(@params.except(:at))
  end

  # delete_all requires an array in the form [sql,block_id,...]
  # the array is passed on thru super
  # then block_id is used to resequence the seq_id
  def Comment.delete_all(ary)
    x = super(ary)
    ii = Comment.where( 'block_id = ?',ary[1]).order(:seq_id)
    ii.each_with_index {|i,j| i.update(seq_id:j+1) }
    x  # the number of deleted rows must be returned
  end

  def Comment.pop_c(block_id,j=1)
    raise ArgumentError,'# to pop must be an integer' unless j.is_a?(Integer)
    raise ArgumentError,'# to pop larger than number of comments' if
        j > Comment.where('block_id = ?',block_id).count
    ii = Comment.
        select(:id,:block_id,:seq_id).
        where('block_id = ?',block_id).
        order(seq_id: :desc).
        limit(j)
    rtrn = []
    ii.each {|i|
      rtrn.unshift(i)
      Comment.delete(i.id)
    }
    rtrn
  end

  def set_seq_id
    max = Comment.where('block_id = ?',self.block_id).maximum(:seq_id) || 0
    self.seq_id = case
                    when !@params.has_key?(:at) #append
                      max += 1
                    when @params[:at] < 1 || @params[:at] > max
                      raise ArgumentError, "Specified :at(#{@params[:at]}) is outside the range 1..#{max}"
                    else
                      ii = Comment.
                          where( 'block_id = ? and seq_id >= ?',self.block_id,@params[:at] ).
                          order(:block_id,:seq_id)
                      ii.each {|i| i.update(seq_id:i.seq_id+1) }
                      @params[:at]
                  end
  end

  def to_s
    self.text
  end

end

end