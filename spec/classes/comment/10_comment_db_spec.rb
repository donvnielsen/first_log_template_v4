module FirstLogicTemplate

  require 'spec_helper'

  describe 'Comment' do

    describe 'Behaviors' do
      def append_comment(o,b)
        i = Comment.new( text: o,block_id: b )
        i.save!
        i
      end

      context 'append and insert' do
        context 'append comments' do
          it 'should have seq_id 1 on first insert' do
            expect(append_comment('Comment 1',10).seq_id).to eq(1)
          end
          it 'should have seq_id 2 on second insert' do
            expect(append_comment('',10).seq_id).to eq(2)
          end
          it 'should have seq_id 3 on third insert' do
            expect(append_comment('Comment 3',10).seq_id).to eq(3)
          end
        end

        context 'insert' do
          before(:all) do
            append_comment('First append',11)  #seq_id = 1
            append_comment('Second append',11) #seq_id = 2
            append_comment('Third append',11)  #seq_id = 3
          end

          it 'should insert an comment into block' do
            expect(Comment.create( text:'First insert',block_id:11,at:2 )).to be_truthy
          end
          it 'should have four comment in block' do
            expect(Comment.where( 'block_id = ?',11 ).count).to eq(4)
          end
          it 'should have placed the inserted row at position two' do
            i = Comment.where('block_id = ? and text = ?',11,'First insert').first
            expect(i.seq_id).to eq(2)
          end
          it 'should incr seq_id of the original rows 2 & 3' do
            i = Comment.where('block_id = ? and text = ?',11,'Second append').first
            expect(i.seq_id).to eq(3)
            i = Comment.where('block_id = ? and text = ?',11,'Third append').first
            expect(i.seq_id).to eq(4)
          end
          it 'should raise error if :at is greater than max seq_id' do
            Comment.create( text: 'invalid insert 99',block_id: 11, seq_id: 99 )
          end
          it 'should raise error if :at is less than one' do
            Comment.create( text: 'invalid insert -1',block_id: 11, seq_id: -1 )
          end
        end
      end

      context 'delete' do
        before(:all) do
          8.times {|i| append_comment("Comment (#{i+1})", 12) }
        end

        it 'should delete nothing with invalid block_id' do
          expect( Comment.delete_all(['block_id = ? and seq_id = ?', 99, 99] ) ).to eq(0)
        end
        it 'should trap invalid seq_id' do
          expect( Comment.delete_all(['block_id = ? and seq_id = ?', 12, 99] ) ).to eq(0)
        end
        it 'should delete the specified instruction from block' do
          expect( Comment.delete_all(['block_id = ? and seq_id = ?', 12, 4]) ).to eq(1)
        end
        it 'should reset seq_ids after delete' do
          ii = Comment.where( 'block_id = ? and seq_id > 3', 12 )
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