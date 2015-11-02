module FirstLogicTemplate

  require 'spec_helper'

  describe Comment do
    context 'properties' do
      it 'should raise error when parameters omitted' do
        expect(Comment.new({}).valid?).to eq(false)
      end
      it 'should raise error when block_id omitted' do
        expect(Comment.new(block_id:nil,text:'Comment').valid?).to eq(false)
      end
      # it 'should raise error when text is omitted' do
      #   expect(Comment.new(block_id:1,text:nil).valid?).to eq(false)
      # end
      it 'should allow a blank string' do
        expect(Comment.new(block_id:1,text:'').valid?).to eq(true)
      end

      it 'should to_s' do
        i = Comment.new(block_id:1,text:'Block comment')
        expect(i.text).to eq('Block comment')
      end
    end

  end

end