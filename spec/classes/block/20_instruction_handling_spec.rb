module FirstLogicTemplate
  require 'spec_helper'

  describe 'Block instruction behaviors' do
    def create_block(desc)
      Template.create(app_id:5,app_name:'Block testing')
      max = Block.maximum(:seq_id)
      Block.create!(
          template_id:Template.last.id,
          seq_id: max.nil? ? 1 : max + 1,
          block:["BEGIN #{desc}",'END']
      )
    end

    def append_ins(o,b)
      parm,arg = Instruction.parse(o)
      Instruction.create!( parm:parm,arg:arg,block_id:b )
    end

    describe 'append and insert' do
      before(:all) do
        @blk = create_block('append')
      end
      context 'append instructions' do
        it 'should have seq_id 1 on first append' do
          expect(append_ins('First append = 1st arg',@blk.id)[:seq_id]).to eq(1)
        end
        it 'should have seq_id 2 on second append' do
          expect(append_ins('Second append = 2nd arg',@blk.id)[:seq_id]).to eq(2)
        end
        it 'should have seq_id 3 on third append' do
          expect(append_ins('Third append = 3rd arg',@blk.id)[:seq_id]).to eq(3)
        end
      end

      context 'insert' do
        before(:all) do
          @blk = create_block('insert test')
          append_ins('First append = 1st arg',@blk.id)  #seq_id = 1
          append_ins('Second append = 2nd arg',@blk.id) #seq_id = 2
          append_ins('Third append = 3rd arg',@blk.id)  #seq_id = 3
        end

        it 'should insert an instruction into block' do
          expect( Instruction.create!(parm:'First insert',arg:'4th arg',block_id:@blk.id,seq_id:2) ).to be_truthy
        end
        it 'should have the correct number of instructions in block' do
          expect(Instruction.where( 'block_id = ?',@blk.id ).count).to eq(4)
        end
        it 'should have placed the inserted row at position two' do
          i = Instruction.where( 'block_id = ? and parm = ?',@blk.id,'First insert' ).first
          expect(i.seq_id).to eq(2)
        end
        it 'should incr seq_id of the original rows 2 & 3' do
          i = Instruction.where( 'block_id = ? and arg = ?',@blk.id,'2nd arg' ).first
          expect(i.seq_id).to eq(3)
          i = Instruction.where( 'block_id = ? and arg = ?',@blk.id,'3rd arg' ).first
          expect(i.seq_id).to eq(4)
        end
        it 'should raise error if seq_id is greater than max seq_id' do
          expect{
            Instruction.create!( parm:'invalid insert',arg:'99 arg',block_id: @blk.id, seq_id: 99 )
          }.to raise_error(ArgumentError)
        end
        it 'should raise error if :at is less than one' do
          expect{
            Instruction.create!( parm:'invalid insert',arg:'-1 arg',block_id: @blk.id, seq_id: -1 )
          }.to raise_error(ArgumentError)
        end
      end
    end

    describe 'Deletereturn an array of blocks instructions' do
      before(:all) do
        @blk = create_block('delete test')
        11.times {|i| append_ins("Path (#{i+1}) = arg #{i+1}", @blk.id) }
      end

      it 'should delete nothing with invalid block_id' do
        expect( Instruction.delete_all(['block_id = ? and seq_id = ?', 99, 99] ) ).to eq(0)
      end
      it 'should trap invalid seq_id' do
        expect( Instruction.delete_all(['block_id = ? and seq_id = ?', @blk.id, 99] ) ).to eq(0)
      end
      it 'should delete the specified instruction from block' do
        expect( Instruction.delete_all(['block_id = ? and seq_id = ?', @blk.id, 4]) ).to eq(1)
      end
      it 'should reset seq_ids after delete' do
        ii = Instruction.where( 'block_id = ?', @blk.id ).order(:seq_id)
        ii.each_with_index {|i,x| expect(i.seq_id).to eq(x+1) }
      end

    end

    context 'pop' do
      before(:all) do
        @blk = create_block('pop test')
        11.times {|i| append_ins("pop (#{i+1}) = arg #{i+1}", @blk.id) }
        Instruction.delete_all(['block_id = ? and seq_id = ?', @blk.id, 4])
      end
      it 'should default to one if n is not specified' do
        ary = Instruction.pop_i(@blk.id)
        expect(ary.size).to eq(1)
        expect(ary[0].seq_id).to eq(10)
        expect(Instruction.where('block_id = ?',@blk.id).count).to eq(9)  #remember, (4) was deleted previously
      end
      it 'should pop n instructions when n is specified' do
        ary = Instruction.pop_i(@blk.id, 3)
        expect(ary.size).to eq(3)
        expect(Instruction.where('block_id = ?',@blk.id).count).to eq(6)
        Instruction.all.where('block_id = ?',@blk.id).each_with_index {|i,x|
          expect(i.seq_id).to eq(x+1)
        }
      end
      it 'should fail when pop n is greater than # of instructions' do
        expect{Instruction.pop_i(@blk.id, 10)}.to raise_error(ArgumentError)
      end

    end
  end

end

