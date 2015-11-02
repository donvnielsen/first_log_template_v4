
module FirstLogicTemplate

  require 'spec_helper'
  require_relative '../../../lib/classes/db'

  describe Instruction do
    context 'Attributes' do
      it 'should raise error when parm value not specified' do
        expect(Instruction.create().valid?).to eq(false)
        expect(Instruction.create(parm:nil).valid?).to eq(false)
      end
      it 'should parse an instruction string' do
        i = 'Work File Directory (path)......... = E:\CLIENT\ABC123\614506\PS01\WORK'
        ii = Instruction.create( ins: i,block_id:1, seq_id:1 )
        expect(ii.valid?).to eq(true)
        expect(ii.parm).to eq('Work File Directory (path)')
        expect(ii.arg).to eq('E:/CLIENT/ABC123/614506/PS01/WORK')
      end

      context 'instruction identifies a file' do
        def file_name_parameters(ins)
          expect(ins.is_fname).to be_truthy
          expect(ins.arg.index('\\')).to be_nil
        end
        it 'should identify file name parms' do
          [
              'ZCF Directory (path & zcf10.dir)............. = E:\pw\AUXILIARY FILES\PROD\ZCF10.DIR',
              'Mail Proc Ctr Dir (path & mpc09.dir)......... = E:\pw\AUXILIARY FILES\PROD\MPC09.DIR',
              '+PER/STD Del Stats (path & dsf.dir).......... = E:\pw\AUXILIARY FILES\PROD\DSF.DIR',
              'Mail Direction (path & facility.dir)......... = E:\pw\AUXILIARY FILES\PROD\FACILITY.DIR',
              'Mail Direction (path & maildirect.dir)....... = E:\pw\AUXILIARY FILES\PROD\MAILDIRECT.DIR',
              'Default Format (path & file.fmt)............. = E:\CLIENT\CMS000\000000\PS01\DATA\PWPREP.FMT',
              'Default DEF (path & file.def)................ = E:\CLIENT\CMS000\000000\PS01\DATA\PWPREP.DEF',
              'Work File Directory (path)......... = E:\CLIENT\ABC123\614506\PS01\WORK',
          ].each {|i|
            file_name_parameters( Instruction.create( ins: i,block_id:1,seq_id:1 ) )
          }
        end
      end
    end

    context 'Properties' do
      before(:all) do
        Instruction.arg_loc = 10
        @p = 'Testing'
        @a = '123'
        @i = Instruction.new(ins:"#{@p} = #{@a}")
      end
      it 'should return a parm' do
        expect(@i.parm).to eq(@p)
        expect(@i.arg).to eq(@a)
      end

      it 'should return the elements as an array' do
        expect(@i.to_a).to eq([@p,@a])
      end

      it 'should return the elements as a hash' do
        expect(@i.to_h).to eq({parm:@p,arg:@a})
      end

      it 'should return a formatted instruction string' do
        expect(@i.to_s).to eq('Testing... = 123')
      end

      context 'file name instructions' do

        it 'should set isfname true when parm contains "directory"' do
          i = Instruction.new( ins:'Work File Directory (path).. = E:/CLIENT/ABC123/614506/',block_id:3 )
          i.save
          expect(i.is_fname?).to be_truthy
        end
        it 'should set isfname true when parm contains "directory"' do
          i = Instruction.new( ins:'Input File Name (path & file name).. = E:/614506/PS01/DATA/PWPREP.TXT',block_id:3 )
          i.save
          expect(i.is_fname?).to be_truthy
        end
        it 'should set isfname true when parm contains "directory"' do
          i = Instruction.new( ins:'Output File(<path & base file name>.*)... = E:/MAILDAT/MAILDAT@@.*',block_id:3 )
          i.save
          expect(i.is_fname?).to be_truthy
        end
      end
    end

    context 'Behaviors' do
      def append_ins(o,b)
        i = Instruction.new( ins: o,block_id: b )
        i.save
        i
      end

    describe 'append and insert' do
      context 'append instructions' do
        it 'should have seq_id 1 on first insert' do
          expect(append_ins('First append = 1st arg',2).seq_id).to eq(1)
        end
        it 'should have seq_id 2 on second insert' do
          expect(append_ins('Second append = 2nd arg',2).seq_id).to eq(2)
        end
        it 'should have seq_id 3 on third insert' do
          expect(append_ins('Third append = 3rd arg',2).seq_id).to eq(3)
        end
      end

      context 'insert' do
        before(:all) do
          append_ins('First append = 1st arg',4)  #seq_id = 1
          append_ins('Second append = 2nd arg',4) #seq_id = 2
          append_ins('Third append = 3rd arg',4)  #seq_id = 3
        end

        it 'should insert an instruction into block' do
          expect(Instruction.create( ins:'First insert = 4th arg',block_id:4,at:2 )).to be_truthy
        end
        it 'should have four instructions in block' do
          expect(Instruction.where( 'block_id = ?',4 ).count).to eq(4)
        end
        it 'should have placed the inserted row at position two' do
          i = Instruction.where( 'block_id = ? and arg = ?',4,'4th arg' ).first
          expect(i.seq_id).to eq(2)
        end
        it 'should incr seq_id of the original rows 2 & 3' do
          i = Instruction.where( 'block_id = ? and arg = ?',4,'2nd arg' ).first
          expect(i.seq_id).to eq(3)
          i = Instruction.where( 'block_id = ? and arg = ?',4,'3rd arg' ).first
          expect(i.seq_id).to eq(4)
        end
        it 'should raise error if :at is greater than max seq_id' do
          Instruction.create( ins: 'invalid insert = 99 arg',block_id: 4, seq_id: 99 )
        end
        it 'should raise error if :at is less than one' do
          Instruction.create( ins: 'invalid insert = -1 arg',block_id: 4, seq_id: -1 )
        end
      end
    end

    describe 'delete' do
      before(:all) do
        8.times {|i| append_ins("Path (#{i+1}) = arg #{i+1}", 6) }
      end

      it 'should delete nothing with invalid block_id' do
        expect( Instruction.delete_all(['block_id = ? and seq_id = ?', 99, 99] ) ).to eq(0)
      end
      it 'should trap invalid seq_id' do
        expect( Instruction.delete_all(['block_id = ? and seq_id = ?', 6, 99] ) ).to eq(0)
      end
      it 'should delete the specified instruction from block' do
        # pp Instruction.where('block_id = ? and seq_id = ?', 6, 4 )
        expect( Instruction.delete_all(['block_id = ? and seq_id = ?', 6, 4]) ).to eq(1)
      end
      it 'should reset seq_ids after delete' do
        ii = Instruction.where( 'block_id = ? and seq_id > 3', 6 )
        ii.each_with_index {|i,x| expect(i.seq_id).to eq(x+4) }
      end

      context 'pop' do
        it 'should delete last instruction from block'
        it 'should fail when pop n is greater than # of instructions'
        it 'should delete n instructions from block'
      end
    end

    end

  end

end
