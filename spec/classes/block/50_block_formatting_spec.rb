module FirstLogicTemplate
  require 'spec_helper'

  describe Block do

    before(:all) do
      @bname = 'Report: Test Block Properties Behaviors'
      @ary = [
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
      @tt = Template.create(app_id:6,app_name:'Block testing')
      b = Block.create!(
          template_id:@tt.id,
          block:@ary
      )
      @block = Block.find(b.id)
    end

    context 'Formatted block as an array' do
      before (:all) do
        @ary = @block.to_a
      end

      it 'should return an array' do
        expect(@ary.is_a?(Array)).to be_truthy
      end
      it 'should format block comments before BEGIN statement' do
        expect(@ary[0]).to eq('* Block comment 1')
        expect(@ary[2]).to eq('* Block comment 2')
      end
      it 'should enclose instructions within BEGIN and END' do
        x = sprintf('BEGIN %s',@bname)
        expect(@ary[3][0,x.length]).to eq(x)
        expect(@ary.last).to eq('END')
      end

      it 'should include formatted instructions' do
        expect(@ary[4,@ary.size-5]).to eq(
                                           [
                                               "instruction 1................................ = 1",
                                               "instruction 2................................ = 2",
                                               "Output Filename.............................. = //a/b/c.txt",
                                               "Output File Name............................. = //x/y/z.txt",
                                               "Working directory............................ = //1/2/3.txt",
                                               "Path name.................................... = //m/n/o.txt",
                                               "instruction 3................................ = arg 3"
                                           ]
                                       )
      end
    end

    context 'Formatted block as a string' do
      before (:all) do
        @ary = @block.to_s.split("\n")
      end

      it 'should return an array' do
        expect(@ary.is_a?(Array)).to be_truthy
      end
      it 'should format block comments before BEGIN statement' do
        expect(@ary[0]).to eq('* Block comment 1')
        expect(@ary[2]).to eq('* Block comment 2')
      end
      it 'should enclose instructions within BEGIN and END' do
        x = sprintf('BEGIN %s',@bname)
        expect(@ary[3][0,x.length]).to eq(x)
        expect(@ary.last).to eq('END')
      end

      it 'should include formatted instructions' do
        expect(@ary[4,@ary.size-5]).to eq(
                                           [
                                               "instruction 1................................ = 1",
                                               "instruction 2................................ = 2",
                                               "Output Filename.............................. = //a/b/c.txt",
                                               "Output File Name............................. = //x/y/z.txt",
                                               "Working directory............................ = //1/2/3.txt",
                                               "Path name.................................... = //m/n/o.txt",
                                               "instruction 3................................ = arg 3"
                                           ]
                                       )
      end
    end

  end
end
