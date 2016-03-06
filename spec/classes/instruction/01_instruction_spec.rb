module FirstLogicTemplate

  require 'spec_helper'

  describe Instruction do

    context 'Accept a string instruction' do
      before(:all) do
        @block = Block.create!(ins:['BEGIN Accept string instruction','END'])
      end

      it 'should accept string instruction ins:parm=arg' do
        expect{Instruction.create(ins:'string instrucion 1 = ok1',block_id:@block.id)}.to_not raise_error
      end
      it 'should reject parm: & arg: when ins:' do
        expect{Instruction.create(
            ins:'string instruction 3 = ok3',parm:'x',arg:'y',block_id:@block.id
        )}.to raise_error(ArgumentError)
      end
      it 'should reject parm: when ins:' do
        expect{Instruction.create(
            ins:'string instruction 3 = ok3',parm:'x',block_id:@block.id
        )}.to raise_error(ArgumentError)
      end
      it 'should reject arg: when ins:' do
        expect{Instruction.create(
            ins:'string instruction 3 = ok3',arg:'y',block_id:@block.id
        )}.to raise_error(ArgumentError)
      end

      it 'should parse the instruction correctly' do
        @ii = Instruction.create(ins:'string instruction 2 = ok2',block_id:@block.id)
        expect(@ii.parm).to eq('string instruction 2')
        expect(@ii.arg).to eq('ok2')
      end
    end

  end

end