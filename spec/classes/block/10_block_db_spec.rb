module FirstLogicTemplate
  require 'spec_helper'

  describe 'validation without array of instructions' do
    before(:all) do
      Template.create(app_id:3,app_name:'Block testing')
      Block.create(template_id:Template.last.id,name:'Instruction array omitted')
    end
    it 'shouldnt have name errors' do
      expect(Block.last.errors[:name].any?).to be_falsey
    end
    it 'shouldnt have seq_id errors' do
      expect(Block.last.errors[:seq_id].any?).to be_falsey
    end
    it 'should have a completely valid block' do
      expect(Block.last.valid?).to be_truthy
    end
  end

  describe Block do
    before(:all) do
      Template.create(app_id:4,app_name:'Test block db specs')
    end

    context 'template_id existence validated' do
      it 'should fail when template_id is omitted' do
        expect{ Block.create!(name:'Template id omitted') }.to raise_error(ActiveRecord::RecordInvalid)
      end
      it 'should fail with invalid template id' do
        expect{
          Block.create!(template_id:99,name:'Invalid template id')
        }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end

    context 'Valid Block Initializations' do
      before(:all) do
        @bname = 'Report: Test Block Properties Behaviors'
        @ary = [
            'instruction 1 = 1',
            'instruction 2 = 2',
            'Output Filename = \\\\a\b\c.txt',
            'Output File Name = \\\\x\y\z.txt',
            'Working directory = \\\\1\2\3.txt',
            'Path name = \\\\m\n\o.txt',
            'instruction 3 = arg 3'
        ]
        @block = [
            '* Block comment 1',
            '',
            '* Block comment 2',
            "BEGIN #{@bname}",
            @ary,
            'END'
          ].flatten
        Block.create!(block:@block,template_id:Template.last.id)
      end

      context 'Properties' do
        it 'should return the block name' do
          expect(Block.last.name).to eq(@bname)
        end
        it 'should store instructions' do
          expect(Block.last.instructions.size).to eq(7)
        end
        it 'should store comments' do
          expect(Block.last.block_comments.size).to eq(3)
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
        Block.last.block_comments.each {|c| expect(c.to_s).to eq(cc[j+=1])}
      end

      context 'Behaviors' do
        it 'should iterate over instructions' do
          j = 0
          Block.last.each_with_index {|i,idx|
            ii = Instruction.parse(@ary[idx])
            expect(i.parm).to eq(ii[0])
            expect(i.arg.to_s).to eq(ii[1].gsub('\\', '/').to_s)
            j+=1
          }
          expect(j).to eq(Block.last.instructions.size)
        end

        it 'should find an instruction' do
          ii = Block.last.find_all_i(/^instruction/i)
          expect(ii.size).to eq(3)
          ['1','2','arg 3'].each_with_index {|arg,i|
            expect(ii[i].arg.to_s).to eq(arg.to_s)
          }
        end

      end

    end

  end

end