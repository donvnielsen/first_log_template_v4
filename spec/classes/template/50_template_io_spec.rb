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

  describe 'importing template' do
    it 'should have a file name'
    it 'should have an application id and description'
    it 'should add an entry to template table and return id'
    it 'should parse blocks'
  end

  describe 'exporting template' do
    it 'should write a new text file template'
  end

end
