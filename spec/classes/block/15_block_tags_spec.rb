module FirstLogicTemplate
  require 'spec_helper'

  describe 'Block tag handling' do
    before(:all) do
      Template.create(app_id:6,app_name:'Block tag testing')
      Block.create(template_id:Template.last.id,name:'instruction array omitted')
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
      expect(Block.last.tags.size).to eq(2)
      Block.last.tags.each {|btag|
        expect(['report','mail.dat'].include?(btag.tag)).to be_truthy
      }
    end
  end

end

