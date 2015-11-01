class Comment < ActiveRecord::Base
  validates_presence_of :block_id
end