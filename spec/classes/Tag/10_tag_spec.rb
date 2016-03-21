module FirstLogicTemplate
  require 'spec_helper'

  describe 'Tag handling using BlockTag' do
    before(:all) do
      Template.create(app_id:6,app_name:'Block tag testing')
      Block.create(template_id:Template.last.id,name:'instruction array omitted')
    end

    it 'should add a tag' do
      expect(Block.add_tag('report').is_a?(Tag)).to be_truthy
      expect(Block.add_tag('mail.dat').is_a?(Tag)).to be_truthy
    end
    it 'should not repeat tags' do
      expect{Block.add_tag('report')}.to_not raise_error
      expect(BlockTags.where('block_id = ? and tag = ?'.Block.last.id,'report').size).to eq(1)
    end
    it 'should identify if it has a tag' do
      expect(Block.tagged?('mail.dat')).to be_truthy
      expect(Block.tagged?('report')).to be_truthy
      expect(Block.tagged?('general')).to_not be_truthy
    end
    it 'return list of tags' do
      expect(Block.tags.size).to eq(2)
      ['report','mail.dat'].each {|tag|
        expect(Block.tags.include?(tag)).to be_truthy
      }
    end
  end

end

