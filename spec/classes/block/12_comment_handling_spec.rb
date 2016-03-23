module FirstLogicTemplate

  require 'spec_helper'

  describe 'Block comment' do
    before(:all) do
      Template.create(app_id:7,app_name:'Comment testing')
    end

    context 'append comments' do
      before(:all) do
        Block.create( template_id:Template.last.id,block:["BEGIN append comments",'END'] )
      end

      it 'should have seq_id 1 on first append' do
        BlockComment.create!(text:'Append 1', block_id:Block.last.id)
        expect(BlockComment.last.seq_id).to eq(1)
      end
      it 'should have seq_id 2 on second append' do
        BlockComment.create!(text:'', block_id:Block.last.id)
        expect(BlockComment.last.seq_id).to eq(2)
      end
      it 'should have seq_id 3 on third append' do
        BlockComment.create!(text:'Append 3', block_id:Block.last.id)
        expect(BlockComment.last.seq_id).to eq(3)
      end
    end

    context 'insert a comment' do
      before(:all) do
        Block.create( template_id:Template.last.id,block:["BEGIN insert comments",'END'] )
        3.times {|i| BlockComment.create!(text:"Append #{i+1}", block_id:Block.last.id) }
      end

      it 'should insert a comment into block' do
        expect(BlockComment.create!(text:'First insert', block_id:Block.last.id, seq_id:2 )).to be_truthy
      end
      it 'should have four comment in block' do
        expect(BlockComment.where('block_id = ?', Block.last.id).count).to eq(4)
      end
      it 'should have placed the inserted row at position two' do
        expect(
            BlockComment.where('block_id = ? and text = ?', Block.last.id, 'First insert').first[:seq_id]
        ).to eq(2)
      end
      it 'should incr seq_id of the original rows 2 & 3' do
        expect(
            BlockComment.where('block_id = ? and text = ?', Block.last.id, 'Append 2').first[:seq_id]
        ).to eq(3)
        expect(
            BlockComment.where('block_id = ? and text = ?', Block.last.id, 'Append 3').first[:seq_id]
        ).to eq(4)
      end
      it 'should raise error if seq_id out of range' do
        expect{
          BlockComment.create!(text: 'invalid insert -1', block_id: Block.last.id, seq_id: -1 )
        }.to raise_error(ArgumentError)
        expect{
          BlockComment.create!(text: 'invalid insert 99', block_id: Block.last.id, seq_id: 99 )
        }.to raise_error(ArgumentError)
      end
    end

    context 'delete' do
      before(:all) do
        Block.create( template_id:Template.last.id,block:["BEGIN Delete comments",'END'] )
        8.times {|i| BlockComment.create!(text:"Append #{i+1}", block_id:Block.last.id) }
      end

      it 'should delete nothing with invalid block_id' do
        expect(BlockComment.delete_all(['block_id = ? and seq_id = ?', 99, 99] ) ).to eq(0)
      end
      it 'should trap invalid seq_id' do
        expect(BlockComment.delete_all(['block_id = ? and seq_id = ?', Block.last.id, -1] ) ).to eq(0)
        expect(BlockComment.delete_all(['block_id = ? and seq_id = ?', Block.last.id, 99] ) ).to eq(0)
      end
      it 'should delete the specified comment from block' do
        expect(BlockComment.delete_all(['block_id = ? and seq_id = ?', Block.last.id, 4]) ).to eq(1)
        expect(BlockComment.where('block_id = ?', Block.last.id).maximum(:seq_id)).to eq(7)
        cc = BlockComment.where('block_id = ?', Block.last.id )
        cc.each_with_index {|c,x| expect(c.seq_id).to eq(x+1) }
      end

    end

    context 'pop' do
      before(:all) do
        Block.create( template_id:Template.last.id,block:["BEGIN Pop comments",'END'] )
        10.times {|i| BlockComment.create!(text:"Append #{i+1}", block_id:Block.last.id) }
      end

      it 'should default to one if n is not specified' do
        cc = BlockComment.pop_c(Block.last.id)
        expect(cc.size).to eq(1)
        expect(cc[0].seq_id).to eq(10)
        expect(BlockComment.where('block_id = ?', Block.last.id).count).to eq(9)
        BlockComment.all.where('block_id = ?', Block.last.id).each_with_index {|i,x|
          expect(i.seq_id).to eq(x+1)
        }
      end
      it 'should pop n instructions when n is specified' do
        cc = BlockComment.pop_c(Block.last.id, 3)
        expect(cc.size).to eq(3)
        expect(BlockComment.where('block_id = ?', Block.last.id).count).to eq(6)
        BlockComment.all.where('block_id = ?', Block.last.id).each_with_index {|i,x|
          expect(i.seq_id).to eq(x+1)
        }
      end
      it 'should fail when pop n is greater than # of instructions' do
        expect{BlockComment.pop_c(Block.last.id, 10)}.to raise_error(ArgumentError)
        expect{BlockComment.pop_c(Block.last.id, -1)}.to raise_error(ArgumentError)
      end

    end

  end

end