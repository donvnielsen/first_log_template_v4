module FirstLogicTemplate
  require 'spec_helper'

  describe Block do
    before(:all) do
      Template.create(app_id:4,app_name:'Test block db specs')
    end

    it 'should fail with invalid template id' do
      expect{
        Block.create!(template_id:99,name:'BEGIN Tests invalid template id')
      }.to raise_error(ActiveRecord::RecordNotFound)
    end

    context 'Valid Block Initialization' do
      before(:all) do
        @bname = 'Report: Test Block Properties Behaviors'
        @block = Block.parse(
          [
            '* Block comment 1',
            '',
            '* Block comment 2',
            "BEGIN #{@bname}",
            'instruction 1 = 1',
            'instruction 2 = 2',
            'Output Filename = \\\\a\b\c.txt',
            'Output File Name = \\\\x\y\z.txt',
            'Working directory = \\\\1\2\3.txt',
            'Path name = \\\\m\n\o.txt',
            'instruction 3 = arg 3',
            'END'
          ]
        )
        Block.create!(template_id:Template.last.id,name:@block[:name])
      end

      context 'Properties' do
        it 'should return the block name' do
          expect(Block.last.name).to eq(@block[:name])
        end
        it 'should store instructions' do
          expect(Instruction.where("block_id = #{Block.last.seq_id}").size).to eq(7)
        end
        it 'should store comments' do
          expect(Comment.where("block_id = #{Block.last.seq_id}").size).to eq(3)
        end
      end

      it 'should return an array of instructions, in the order they were given' do
        ii = [
            "instruction 1................................ = 1",
            "instruction 2................................ = 2",
            "Output Filename.............................. = //a/b/c.txt",
            "Output File Name............................. = //x/y/z.txt",
            "Working directory............................ = //1/2/3.txt",
            "Path name.................................... = //m/n/o.txt",
            "instruction 3................................ = arg 3"
        ]
        j = -1
        Block.last.instructions.each {|i| expect(i.to_s).to eq(ii[j+=1]) }
      end

      it 'should return an array of comments, in the order they were given' do
        cc = [
            '* Block comment 1',
            '',
            '* Block comment 2',
        ]
        j = -1
        Block.last.comments.each {|c| expect(c.to_s).to eq(cc[j+=1])}
      end

      context 'Behaviors' do
        it 'should iterate over instructions' do
          j = 0
          Block.last.each_with_index {|i,idx|
            ii = Instruction.parse(@ary[idx])
            expect(i.parm).to eq(ii[0])
            expect(i.arg).to eq(ii[1].gsub('\\', '/'))
            j+=1
          }
          expect(j).to eq(Block.last.instructions.size)
        end

        it 'should find an instruction' do
          ii = Block.last.find_all_i(/^instruction/i)
          expect(ii.size).to eq(3)
          ['1','2','arg 3'].each_with_index {|arg,i| expect(ii[i].arg).to eq(arg) }
        end

        it 'should be able to clone itself'
        # create new block instance
        # retrieve instructions and send them
        # retrieve comments and send them
      end

      context 'File names in instructions' do
        before(:all) do
          @fnames = Block.last.file_names
          puts @fnames
        end

        it 'should return an array containing the file names' do
          expect(@fnames.is_a?(Array)).to be_truthy
          expect(@fnames.size).to eq(2)
        end

        it 'should have correct values' do
          ['//a/b/c.txt','//x/y/z.txt'].each_with_index{|arg,i|
            expect(@fnames[i]).to eq(arg)
          }
        end

      end
    end

  end

end