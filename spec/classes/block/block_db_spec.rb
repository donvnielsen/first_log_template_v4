module FirstLogicTemplate
  require 'spec_helper'

  describe Block do
    context 'Valid Initialization' do
      before(:all) do
        @ary = [
          '* Block comment 1',
          '',
          '* Block comment 2',
          'BEGIN Test Block Name',
          'instruction 1 = 1',
          'instruction 2 = 2',
          'Output Filename = \\a\b\c.txt',
          'Output File Name = \\x\y\z.txt',
          'Working directory = \\1\2\3.txt',
          'Path name = \\m\n\o.txt',
          'instruction 3 = arg 3',
          'END'
        ]
        @block = Block.create(block:@ary)
      end

      context 'Properties' do
        it 'should return the block name' do
          expect(@block.name).to eq('Test Block Name')
        end
        it 'should return seq_id' do
          expect(@block.seq_id).to eq(1)
        end
        it 'should store instructions' do
          expect(Instruction.where('block_id = 1').size).to eq(7)
        end
        it 'should store comments'
        #   expect(Comment.where('block_id = 1').size).to eq(3)
        # end
      end

      context 'Instructions' do
        it 'should return an array of instructions'
        it 'should return instructions in the order they were given'
      end

      context 'Comments' do
        it 'should return an array of two comments'
        it 'should return comments in the order they were given'
      end

      context 'Behaviors' do
        it 'should iterate over instructions'
        it 'should find an instruction'
        it 'should append an instruction'
        it 'should insert an instruction at a specified location'
        it 'should delete an instruction'
        it 'should be able to compare to another block'
        it 'should be able to clone itself'
      end

      context 'Formatting block' do
        it 'should enclose instructions within BEGIN and END'
        it 'should put block name after BEGIN'
        it 'should format block comments before BEGIN statement'
      end

      context 'File names in instructions' do
        before(:all) do
          @ary = <<eoo_i
BEGIN Test File Names
instruction 1 = 1
Output File Name = \\x\y\z.txt
instruction 2 = 2
Output Filename = \\a\b\c.txt
Output File Name = \\1\2\3.txt
instruction 3 = 3
END
eoo_i
        end

        it 'should return an array containing the 3 file names'
      end
    end

  end

end