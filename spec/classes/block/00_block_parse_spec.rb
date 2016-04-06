module FL_Template
  require 'spec_helper'

  describe 'Block parse' do
    context 'Invalid block passed' do
      it 'should catch when block is not an Array' do
        expect{Block.parse('Block')}.to raise_error(ArgumentError)
      end
      it 'should catch an empty array' do
        expect{Block.parse(nil)}.to raise_error(ArgumentError)
        expect{Block.parse([])}.to raise_error(ArgumentError)
      end
      it 'should catch when no begin statement' do
        expect{Block.parse(['I1 = 1','i2.. = 2','I3.... = 3','END'])}.to raise_error(ArgumentError)
      end
      it 'should catch when no end statement' do
        expect{Block.parse(['BEGIN Some block name','I1 = 1','i2.. = 2','I3.... = 3'])}.to raise_error(ArgumentError)
      end
      it 'should catch when end is not final statement' do
        expect{Block.parse(['BEGIN Some block name','I1 = 1','i2.. = 2','I3.... = 3','x'])}.to raise_error(ArgumentError)
      end
    end

    context 'Empty block' do
      before(:all) do
        @blk = Block.parse(['BEGIN Block Name','END'])
      end
      it 'should have parsed the block name' do
        expect(@blk[:name]).to eq('Block Name')
      end
      it 'it should have identified zero instructions' do
        expect(@blk[:ii].size).to eq(0)
      end
      it 'it should have identified zero comments' do
        expect(@blk[:cc].size).to eq(0)
      end
    end

    context 'Valid block passed' do
      before(:all) do
        @blk = Block.parse(['BEGIN Some block name','I1 = 1','i2.. = 2','I3.... = 3','END'])
      end

      it 'should identify block name' do
        expect(@blk[:name]).to eq('Some block name')
      end

      context 'parsed instructions' do
        it 'should parse the array of instructions' do
          expect(@blk[:ii].is_a?(Array)).to be_truthy
          expect(@blk[:ii].size).to eq(3)
          [['I1','1'],['i2','2'],['I3','3']].each_with_index{|ary,i|
            expect(ary).to eq(Instruction.parse(@blk[:ii][i]))
          }
        end
      end

    end

    context 'Valid block with comments passed' do
      before(:all) do
        @blk = Block.parse(
            ['* Comment 1','','* Comment 2','BEGIN Some block name','I1 = 1','i2.. = 2','I3.... = 3','END']
        )
      end

      it 'should identify block name' do
        expect(@blk[:name]).to eq('Some block name')
      end

      context 'parsed instructions' do
        it 'should parse the array of instructions' do
          expect(@blk[:ii].is_a?(Array)).to be_truthy
          expect(@blk[:ii].size).to eq(3)
          [['I1','1'],['i2','2'],['I3','3']].each_with_index{|ary,i|
            expect(ary).to eq(Instruction.parse(@blk[:ii][i]))
          }
        end
      end

      context 'parsed comments' do
        it 'should parse the array of instructions' do
          expect(@blk[:cc].is_a?(Array)).to be_truthy
          expect(@blk[:cc].size).to eq(3)
          ['* Comment 1','','* Comment 2'].each_with_index{|ary,i|
            expect(ary).to eq(@blk[:cc][i])
          }
        end
      end
    end

  end
end