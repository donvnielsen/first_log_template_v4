module FirstLogicTemplate

  require 'spec_helper'

  describe 'Comment' do
    before(:all) do
      Template.create(app_id:7,app_name:'Comment testing')
    end

    context 'append comments' do
      before(:all) do
        Block.create( template_id:Template.last.id,block:["BEGIN append comments",'END'] )
      end

      it 'should have seq_id 1 on first append' do
        Comment.create!(text:'Append 1',block_id:Block.last.id)
        expect(Comment.last.seq_id).to eq(1)
      end
      it 'should have seq_id 2 on second append' do
        Comment.create!(text:'',block_id:Block.last.id)
        expect(Comment.last.seq_id).to eq(2)
      end
      it 'should have seq_id 3 on third append' do
        Comment.create!(text:'Append 3',block_id:Block.last.id)
        expect(Comment.last.seq_id).to eq(3)
      end
    end

    context 'insert a comment' do
      before(:all) do
        Block.create( template_id:Template.last.id,block:["BEGIN insert comments",'END'] )
        3.times {|i| Comment.create!(text:"Append #{i+1}",block_id:Block.last.id) }
      end

      it 'should insert a comment into block' do
        expect(Comment.create!( text:'First insert',block_id:Block.last.id,seq_id:2 )).to be_truthy
      end
      it 'should have four comment in block' do
        expect(Comment.where( 'block_id = ?',Block.last.id).count).to eq(4)
      end
      it 'should have placed the inserted row at position two' do
        expect(
            Comment.where('block_id = ? and text = ?',Block.last.id,'First insert').first[:seq_id]
        ).to eq(2)
      end
      it 'should incr seq_id of the original rows 2 & 3' do
        expect(
            Comment.where('block_id = ? and text = ?',Block.last.id,'Append 2').first[:seq_id]
        ).to eq(3)
        expect(
            Comment.where('block_id = ? and text = ?',Block.last.id,'Append 3').first[:seq_id]
        ).to eq(4)
      end
      it 'should raise error if seq_id out of range' do
        expect{
          Comment.create!( text: 'invalid insert -1',block_id: Block.last.id, seq_id: -1 )
        }.to raise_error(ArgumentError)
        expect{
          Comment.create!( text: 'invalid insert 99',block_id: Block.last.id, seq_id: 99 )
        }.to raise_error(ArgumentError)
      end
    end

    context 'delete' do
      before(:all) do
        Block.create( template_id:Template.last.id,block:["BEGIN Delete comments",'END'] )
        8.times {|i| Comment.create!(text:"Append #{i+1}",block_id:Block.last.id) }
      end

      it 'should delete nothing with invalid block_id' do
        expect( Comment.delete_all(['block_id = ? and seq_id = ?', 99, 99] ) ).to eq(0)
      end
      it 'should trap invalid seq_id' do
        expect( Comment.delete_all(['block_id = ? and seq_id = ?', Block.last.id, -1] ) ).to eq(0)
        expect( Comment.delete_all(['block_id = ? and seq_id = ?', Block.last.id, 99] ) ).to eq(0)
      end
      it 'should delete the specified comment from block' do
        expect( Comment.delete_all(['block_id = ? and seq_id = ?', Block.last.id, 4]) ).to eq(1)
        expect( Comment.where('block_id = ?',Block.last.id).maximum(:seq_id)).to eq(7)
        cc = Comment.where( 'block_id = ?', Block.last.id )
        cc.each_with_index {|c,x| expect(c.seq_id).to eq(x+1) }
      end

    end

    context 'pop' do
      before(:all) do
        @blk = create_block('pop test')
        11.times {|i| append_comment("pop (#{i+1}) = arg #{i+1}", @blk.id) }
        Comment.delete_all(['block_id = ? and seq_id = ?', @blk.id, 4])
      end
      it 'should default to one if n is not specified' do
        ary = Comment.pop_c(@blk.id)
        expect(ary.size).to eq(1)
        expect(ary[0].seq_id).to eq(10)
        expect(Comment.where('block_id = ?',@blk.id).count).to eq(9)  #remember, (4) was deleted previously
      end
      it 'should pop n instructions when n is specified' do
        ary = Comment.pop_c(@blk.id, 3)
        expect(ary.size).to eq(3)
        expect(Comment.where('block_id = ?',@blk.id).count).to eq(6)
        Comment.all.where('block_id = ?',@blk.id).each_with_index {|i,x|
          expect(i.seq_id).to eq(x+1)
        }
      end
      it 'should fail when pop n is greater than # of instructions' do
        expect{Comment.pop_c(@blk.id, 10)}.to raise_error(ArgumentError)
      end

    end

  end

end