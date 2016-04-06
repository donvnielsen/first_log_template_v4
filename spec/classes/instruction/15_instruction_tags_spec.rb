module FL_Template
  require 'spec_helper'

  describe 'Instruction tag handling' do
    before(:all) do
      Template.create!(app_id:9,app_name:'Instruction tag testing')
      Block.create!(
          template_id:Template.last.id,
          name:'Instruction tag testing',
          block:[
              'BEGIN Instruction tag',
              'Instruction tag = x',
              'END'
          ]
      )
      @ix = Block.last.instructions.first
    end

    it 'should not have any tags for instruction' do
      expect(InstructionTag.where('instruction_id = ?',@ix.id).count).to eq(0)
    end

    context 'Add instruction tag' do
      it 'should add a tag' do
        expect(@ix.add_tag('add_tag').is_a?(InstructionTag)).to be_truthy
      end
      it 'should not repeat tags' do
        expect{@ix.add_tag('add_tag')}.to_not raise_error
      end
      it 'return list of tags' do
        expect(@ix.instruction_tags.size).to eq(1)
        expect(@ix.tagged?('add_tag') ).to be_truthy
      end
    end

    context 'Post tags' do
      before(:all) do
        @id = Instruction.create!(
            block_id:Block.last.id,
            ins:'Work File Directory (path) = E:\pw\AUXILIARY FILES\PROD'
        )
        @if = Instruction.create!(
            block_id:Block.last.id,
            ins:'Directory and File name = E:\pw\AUXILIARY FILES\PROD\DSF.DIR'
        )
      end

      it 'should identify if it has a tag' do
        expect(@id.tagged?('directory')).to be_truthy
        expect(@if.tagged?('file_name')).to be_truthy
      end

      it 'should fail identifying tags' do
        expect(@id.tagged?('file_name')).to be_falsey
        expect(@if.tagged?('directory')).to be_falsey
      end
    end

    context 'searching for tags' do
      before(:all) do
        Instruction.create!(
            block_id:Block.last.id,
            ins:'Search instruction tags = xxx'
        )
        Instruction.last.add_tag('report')
        Instruction.last.add_tag('entry_pt')
        Instruction.last.add_tag('version')
      end
      it 'should find a single tag value' do
        expect(Instruction.last.tagged?('version')).to be_truthy
      end
      it 'should find any one of array' do
        expect(Instruction.last.tagged?(['version','entry_pt'])).to be_truthy
      end
    end

    context 'remove tags' do
      before(:all) do
        ['report','version','file_name','directory'].each {|t| @ix.add_tag(t) }
      end
      it 'should return error when removing non-existent tag' do
        expect{@ix.remove_tag('xxx')}.to_not raise_error #(ArgumentError)
      end
      it 'should remove the specified tag' do
        expect{@ix.remove_tag('file_name')}.to_not raise_error
        expect(InstructionTag.where('instruction_id = ?',@ix.id).size).to eq(4)
      end
      it 'should remove all tags' do
        expect{@ix.remove_tag(:all)}.to_not raise_error
        expect(InstructionTag.where('instruction_id = ?',@ix.id).size).to eq(0)
      end
    end
  end

end

