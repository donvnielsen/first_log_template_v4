module FirstLogicTemplate
  require 'spec_helper'

  describe 'Formatting template' do
    before(:all) do
      Template.create(app_id:3,app_name:'Block testing')

      (1..5).each {|bb|
        Block.create(template_id:Template.last.id,name:"Template format block #{bb}")
        (1..2).each{|cc|
          BlockComment.create!(text:"* Format comment #{cc}", block_id:Block.last.id)
        }
        (1..4).each {|ii|
          Instruction.create(
              parm:"Format instruction #{ii}",
              arg:"arg #{ii}",
              block_id:Block.last.id
          )
        }
      }
      @ft = Template.last.to_a
    end

    it 'should have correct number of lines' do
      expect(@ft.size).to eq(5*(2+4+2))
    end
    it 'should display template' do
      pp @ft
    end
  end
end
