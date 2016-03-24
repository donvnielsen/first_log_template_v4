module FirstLogicTemplate
  require 'spec_helper'

  describe 'Block tag handling' do
    before(:all) do
      Template.create(app_id:6,app_name:'Block tag testing')
    end

    context 'Add block tag' do
      before(:all) do
        Block.create(template_id:Template.last.id,name:'Add block tag')
      end
      it 'should add a tag' do
        expect(Block.last.add_tag('report').is_a?(BlockTag)).to be_truthy
        expect(Block.last.add_tag('mail.dat').is_a?(BlockTag)).to be_truthy
      end
      it 'should not repeat tags' do
        expect{Block.last.add_tag('report')}.to_not raise_error
        expect(BlockTag.where('block_id = ? and tag = ?',Block.last.id,'report').size).to eq(1)
      end
      it 'should identify if it has a tag' do
        expect(Block.last.tagged?('mail.dat')).to be_truthy
        expect(Block.last.tagged?('report')).to be_truthy
        expect(Block.last.tagged?('general')).to_not be_truthy
      end
      it 'return list of tags' do
        expect(Block.last.block_tags.size).to eq(2)
        Block.last.block_tags.each {|btag|
          expect(['report','mail.dat'].include?(btag.tag)).to be_truthy
        }
      end
    end

    context 'remove tags' do
      before(:all) do
        Block.create(template_id:Template.last.id,name:'remove tag')
        Block.last.add_tag('report')
        Block.last.add_tag('version')
        Block.last.add_tag('file_name')
        Block.last.add_tag('directory')
        Block.last.add_tag('segment')
      end
      it 'should return error when removing non-existent tag' do
        expect{Block.last.remove_tag('xxx')}.to raise_error(ArgumentError)
      end
      it 'should remove the specified tag' do
        expect{Block.last.remove_tag('file_name')}.to_not raise_error
        expect(Block.last.block_tags.size).to eq(4)
      end
      it 'should remove all tags' do
        expect{Block.last.remove_tag(:all)}.to_not raise_error
        expect(Block.last.block_tags.size).to eq(0)
      end
    end
  end

end

