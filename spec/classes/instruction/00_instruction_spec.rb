module FirstLogicTemplate

require 'spec_helper'

# BEGIN/END are not instructions
# Comments are not instructions
describe Instruction do

  context 'arg_loc' do
    it 'should return 45 as the default arg location' do
      expect(Instruction.arg_loc).to eq(45)
    end
    it 'should return an exception when value is invalid' do
      expect{Instruction.arg_loc='a1Z'}.to raise_error(ArgumentError)
    end
    it 'should allow the argument location value to be re-assigned' do
      Instruction.arg_loc=30
      expect(Instruction.arg_loc).to eq(30)
    end
  end

  context 'instruction has file name test' do
    it 'should detect parm that indicates file name' do
      ['directory','file name','path','filename'].each {|i|
        expect(Instruction.has_fname?(i)).to eq(true)
      }
    end
    it 'should overlook non-file parameters' do
      ['begin','toast','zip range','whatever'].each {|i|
        expect(Instruction.has_fname?(i)).to eq(false)
      }
    end
  end

  context 'instructions parse behaviors' do
    it 'should parse a parm = argument string' do
      result = Instruction.parse('parm.... = arg')
      expect(result[0]).to eq('parm')
      expect(result[1]).to eq('arg')
    end
    it 'should fail to parse a bad instruction' do
      expect {Instruction.parse('Invalid parameter setup.... argument')}.to raise_error(ArgumentError)
    end
    it 'should fail to parse a nil instruction' do
      expect {Instruction.parse}.to raise_error(ArgumentError)
      expect {Instruction.parse(nil)}.to raise_error(ArgumentError)
    end

    context 'BEGIN' do
      it 'should identify a begin parameter with line' do
        result = Instruction.parse('BEGIN General Presort 8.00c.06 ====')
        expect(result[0]).to eq('BEGIN')
        expect(result[1]).to eq('General Presort 8.00c.06')
      end
      it 'should identify a begin parameter without line' do
        result = Instruction.parse('BEGIN General Presort 8.00c.06')
        expect(result[0]).to eq('BEGIN')
        expect(result[1]).to eq('General Presort 8.00c.06')
      end
      it 'should identify an end parameter' do
        result = Instruction.parse('END')
        expect(result[0]).to eq('END')
        expect(result[1]).to be_nil
      end
    end

  end

end

end