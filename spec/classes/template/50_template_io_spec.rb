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
      # pp @ft
    end

  end

  describe 'importing template' do
    before(:all) do
      Template.create(app_id:10,app_name:'File import testing')
      Template.last.import('./spec/data/test_template.txt')
      # Template.last.import('./spec/data/test_presort_template.pst')
    end
    it 'should have a file name' do
      expect(Template.last.input_file_name).to eq('./spec/data/test_template.txt')
    end
    it 'should correct number of blocks' do
      expect(Template.last.blocks.count).to eq(12)
    end
    it 'should have correct number of instructions' do
      i = 0
      Template.last.blocks.each {|b| i += b.instructions.count }
      expect(i).to eq(427)
    end

    context 'Imported block 1' do
      before(:all) do
        @b = Template.last.blocks[0]
      end
      it 'should have name' do
        expect(@b.name).to eq('General Presort 8.00c.06')
      end
      it 'should have comments' do
        expect(@b.block_comments.count).to eq(2)
      end
      it 'should have instructions' do
        expect(@b.instructions.count).to eq(3)
      end
    end

    context 'Imported block 2' do
      before(:all) do
        @b = Template.last.blocks[1]
      end
      it 'should have name' do
        expect(@b.name).to eq('Execution')
      end
      it 'should have comments' do
        expect(@b.block_comments.count).to eq(1)
      end
      it 'should have instructions' do
        expect(@b.instructions.count).to eq(17)
      end
      it 'should have last instruction tagged' do
        expect(@b.instructions.last.tagged?('directory')).to be_truthy
      end
    end

    context 'Imported block 3' do
      before(:all) do
        @b = Template.last.blocks[2]
      end
      it 'should have name' do
        expect(@b.name).to eq('Intelligent Mail')
      end
      it 'should have comments' do
        expect(@b.block_comments.count).to eq(4)
      end
      it 'should have instructions' do
        expect(@b.instructions.count).to eq(12)
      end
    end

  end


  describe 'exporting template' do
    it 'should write a new text file template'
  end

end
