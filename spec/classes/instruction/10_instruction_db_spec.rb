
module FL_Template

  require 'spec_helper'

  describe Instruction do

    def create_block(desc)
      Template.create(app_id:7,app_name:'Block testing')
      Block.create( template_id:Template.last.id,block:["BEGIN #{desc}",'END'] )
    end

    it 'should raise error when parm value not specified' do
      expect{Instruction.create(block_id:nil).valid?}.to raise_error(ArgumentError)
    end

    context 'Attributes' do
      before(:all) do
        create_block('Attributes')
        parm,arg = Instruction.parse(
          'Work File Directory (path)......... = E:\CLIENT\ABC123\614506\PS01\WORK'
        )
        Instruction.create( parm:parm,arg:arg,block_id:Block.last.id )
      end
      it 'should parse the parm' do
        expect(Instruction.last.parm).to eq('Work File Directory (path)')
      end
      it 'should parse the arg, transform the file name' do
        expect(Instruction.last.arg).to eq('E:/CLIENT/ABC123/614506/PS01/WORK')
      end
      it 'should be a valid instruction' do
       expect(Instruction.last.valid?).to eq(true)
      end

      context 'instruction identifies a file' do
        def file_name_parameters(ins)
          expect(ins.is_fname).to be_falsey # path name
          expect(ins.arg.index('\\')).to be_nil
        end

        before(:all) do
          create_block('Attributes')
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
            parm,arg = Instruction.parse(i)
            # file_name_parameters( Instruction.create!( parm:parm,arg:arg,block_id:Block.last.id ) )
          }
        end
      end
    end

    context 'Properties' do
      before(:all) do
        create_block('Properties')
        Instruction.arg_loc = 10
        @p = 'Testing'
        @a = '123'
        @i = Instruction.new(parm:@p,arg:@a,block_id:Block.last.id)
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

    end

    context 'Behaviors' do
      def append_ins(o,b)
        parm,arg = Instruction.parse(o)
        Instruction.create( parm:parm,arg:arg,block_id:b )
      end

      describe 'append and insert' do
        before(:all) do
          create_block('append')
        end
        context 'append instructions' do
          it 'should have seq_id 1 on first append' do
            expect(append_ins('First append = 1st arg',Block.last.id)[:seq_id]).to eq(1)
          end
          it 'should have seq_id 2 on second append' do
            expect(append_ins('Second append = 2nd arg',Block.last.id)[:seq_id]).to eq(2)
          end
          it 'should have seq_id 3 on third append' do
            expect(append_ins('Third append = 3rd arg',Block.last.id)[:seq_id]).to eq(3)
          end
        end

        context 'insert' do
          before(:all) do
            create_block('insert test')
            append_ins('First append = 1st arg',Block.last.id)  #seq_id = 1
            append_ins('Second append = 2nd arg',Block.last.id) #seq_id = 2
            append_ins('Third append = 3rd arg',Block.last.id)  #seq_id = 3
          end

          it 'should insert an instruction into block' do
            expect( Instruction.create(parm:'First insert',arg:'4th arg',block_id:Block.last.id,seq_id:2) ).to be_truthy
          end
          it 'should have the correct number of instructions in block' do
            expect(Block.last.instructions.count).to eq(4)
          end
          it 'should have placed the inserted row at position two' do
            i = Instruction.where( 'block_id = ? and parm = ?',Block.last.id,'First insert' ).first
            expect(i.seq_id).to eq(2)
          end
          it 'should incr seq_id of the original rows 2 & 3' do
            i = Instruction.where( 'block_id = ? and arg = ?',Block.last.id,'2nd arg' ).first
            expect(i.seq_id).to eq(3)
            i = Instruction.where( 'block_id = ? and arg = ?',Block.last.id,'3rd arg' ).first
            expect(i.seq_id).to eq(4)
          end
          it 'should raise error if seq_id is greater than max seq_id' do
            expect{
              Instruction.create( parm:'invalid insert',arg:'99 arg',block_id: Block.last.id, seq_id: 99 )
            }.to raise_error(ArgumentError)
          end
          it 'should raise error if :at is less than one' do
            expect{
              Instruction.create( parm:'invalid insert',arg:'-1 arg',block_id: Block.last.id, seq_id: -1 )
            }.to raise_error(ArgumentError)
          end
        end
      end

      describe 'delete' do
        before(:all) do
          create_block('delete test')
          11.times {|i| append_ins("Path (#{i+1}) = arg #{i+1}", Block.last.id) }
        end

        it 'should delete nothing with invalid block_id' do
          expect( Instruction.delete_all(['block_id = ? and seq_id = ?', 99, 99] ) ).to eq(0)
        end
        it 'should trap invalid seq_id' do
          expect( Instruction.delete_all(['block_id = ? and seq_id = ?', Block.last.id, 99] ) ).to eq(0)
        end
        it 'should delete the specified instruction from block' do
          expect( Instruction.delete_all(['block_id = ? and seq_id = ?', Block.last.id, 4]) ).to eq(1)
        end
        it 'should reset seq_ids after delete' do
          Block.last.instructions.each_with_index {|i,x| expect(i.seq_id).to eq(x+1) }
        end

      end

      context 'pop' do
        before(:all) do
          create_block('pop test')
          11.times {|i| append_ins("pop (#{i+1}) = arg #{i+1}", Block.last.id) }
          Instruction.delete_all(['block_id = ? and seq_id = ?', Block.last.id, 4])
        end
        it 'should default to one if n is not specified' do
          ary = Instruction.pop_i(Block.last.id)
          expect(ary.size).to eq(1)
          expect(ary[0].seq_id).to eq(10)
          expect(Block.last.instructions.count).to eq(9)  #remember, (4) was deleted previously
        end
        it 'should pop n instructions when n is specified' do
          ary = Instruction.pop_i(Block.last.id, 3)
          expect(ary.size).to eq(3)
          expect(Block.last.instructions.count).to eq(6)
          Block.last.instructions.each_with_index {|i,x| expect(i.seq_id).to eq(x+1) }
        end
        it 'should fail when pop n is greater than # of instructions' do
          expect{Instruction.pop_i(Block.last.id, 10)}.to raise_error(ArgumentError)
        end

      end
    end

    context 'Formats' do
      before(:all) do
        @prm = 'Test instruction formatting'
        @arg = 'Format arg'
        Instruction.create!( parm:@prm,arg:@arg,block_id:Block.last.id )
      end
      it 'to_h' do
        expect(Instruction.last.to_h).to eq({parm:@prm,arg:@arg})
      end
      it 'to_a' do
        expect(Instruction.last.to_a).to eq([@prm,@arg])
      end
      context 'string output' do
        it 'to_s 30' do
          Instruction.arg_loc=(30)
          expect(Instruction.last.to_s).to eq("Test instruction formatting... = Format arg")
        end
        it 'to_s 40' do
          Instruction.arg_loc=(40)
          expect(Instruction.last.to_s).to eq("Test instruction formatting............. = Format arg")
        end
        it 'to_s 45' do
          Instruction.arg_loc=(45)
          expect(Instruction.last.to_s).to eq("Test instruction formatting.................. = Format arg")
        end
      end
    end
  end

end
