module FirstLogicTemplate
  require 'spec_helper'

  describe Block do
    context 'Valid Block Initialization' do
      before(:all) do
        @bname = 'Report: Test Block Properties Behaviors'
        @ary = [
          '* Block comment 1',
          '',
          '* Block comment 2',
          "BEGIN #{@bname}",
          'instruction 1 = 1',
          'instruction 2 = 2',
          'Output Filename = \\a\b\c.txt',
          'Output File Name = \\x\y\z.txt',
          'Working directory = \\1\2\3.txt',
          'Path name = \\m\n\o.txt',
          'instruction 3 = arg 3',
          'END'
        ]
        @block = Block.create!(ins:@ary)
      end

      context 'Properties' do
        it 'should return the block name' do
          expect(@block.name).to eq(@bname)
        end
        it 'should store instructions' do
          expect(Instruction.where("block_id = #{@block.seq_id}").size).to eq(7)
        end
        it 'should store comments' do
          expect(Comment.where("block_id = #{@block.seq_id}").size).to eq(3)
        end
        it 'should set is_report flag' do
          expect(@block.is_report?).to be_truthy
        end
      end

      it 'should return an array of instructions, in the order they were given' do
        expect(Block.find(@block.id).instructions).
          to eq([
                  "instruction 1................................ = 1",
                  "instruction 2................................ = 2",
                  "Output Filename.............................. = /a/b/c.txt",
                  "Output File Name............................. = /x/y/z.txt",
                  "Working directory............................ = /1/2/3.txt",
                  "Path name.................................... = /m/n/o.txt",
                  "instruction 3................................ = arg 3"
                ])
      end

      it 'should return an array of comments, in the order they were given' do
        expect(Block.find(@block.id).comments).
          to eq([
                  '* Block comment 1',
                  '',
                  '* Block comment 2',
                ])
      end

      context 'Behaviors' do
        it 'should iterate over instructions' do
          j = 0
          @block.each_with_index {|i,idx|
            ii = Instruction.parse(@ary[idx])
            expect(i.parm).to eq(ii[0])
            expect(i.arg).to eq(ii[1].gsub('\\', '/'))
            j+=1
          }
          expect(j).to eq(@block.instructions.size)
        end

        it 'should find an instruction' do
          ii = @block.find_all_i(/^instruction/i)
          expect(ii.size).to eq(3)
          ['1','2','arg 3'].each_with_index {|arg,i| expect(ii[i].arg).to eq(arg) }
        end
        it 'should append an instruction'
        it 'should insert an instruction at a specified location'
        it 'should delete an instruction'
        it 'should be able to clone itself'
        # create new block instance
        # retrieve instructions and send them
        # retrieve comments and send them
      end

      context 'Formatting block' do
        it 'should format block comments before BEGIN statement'
        it 'should enclose instructions within BEGIN and END'
        it 'should put block name after BEGIN'
        it 'should include formatted instructions'
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