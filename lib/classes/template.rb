module FirstLogicTemplate

class Template < ActiveRecord::Base
  self.table_name = 'fl_templates'
  has_many :blocks,:dependent => :destroy
  include Enumerable

  validates :app_name,:app_id, presence: true
  before_save :set_create_date, on: :create

  include FL_Regex

  # block iterator
  def each(&block)
    self.blocks.each(&block)
  end

  def to_a
    tt = []
    self.blocks.each{|b| tt << b.to_a }
    tt.flatten
  end

  def load_template_err(err,msg,b)
    puts "Error loading template, block #{b}",@origin
    raise err,msg
  end

  # Imports template file
  def import(fl)
    self.transaction do

      raise IOError, "File #{fl} cannot be found" unless FileTest.exists?(fl)
      self.update(input_file_name:fl)

      # locate BEGIN and END of each block
      tmp = File.open(fl).readlines
      idx = [[nil,nil]]
      tmp.each_with_index {|i,j|
        case
          when FL_Regex::RGX_BEGIN.match(i)
            raise RuntimeError,'No end found found for begin' unless idx.last[1].nil?
            idx.last[0] = j
          when FL_Regex::RGX_END.match(i)
            raise RuntimeError,'No matching begin' if idx.last[0].nil?
            idx.last[1] = j

            # adjust beginning for leading comments
            idx.last[0].downto(idx[-2].nil? ? 1 : idx[-2][1]) {|k|
              break unless FL_Regex::RGX_COMMENT.match(tmp[k-1])
              idx.last[0] -= 1
            }
            idx <<[nil,nil]
        end
      }
      idx.pop  # delete last index created by template's final END
      idx.each {|i,j| Block.create(template_id:self.id,block:tmp.slice(i..j)) }

    end
  end

  def export(fl)
    File.open(fl,'w') {|of| self.blocks.each{|b| of.puts b.to_s << "\n"}  }
  end

  protected

  def set_create_date
    self.create_date = Time.now
  end


  # load entire template

  # find begin
  # backup while comments are found
  #   that is start of block
  # find end
  # create block
  # loop


end

end