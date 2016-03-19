module FirstLogicTemplate
  require 'spec_helper'

  describe 'creating a template' do
    it 'should fail without any params' do
      expect{Template.create!()}.to raise_error(ActiveRecord::RecordInvalid)
    end
    it 'should fail without an app_name' do
      expect{Template.create!(app_id:1)}.to raise_error(ActiveRecord::RecordInvalid)
    end
    it 'should have an application id' do
      expect{Template.create!(app_name:'Test Template')}.to raise_error(ActiveRecord::RecordInvalid)
    end
    it 'should add an entry to template table and return id' do
      id = 1; nme = 'Create template'
      Template.create!(app_id:id,app_name:nme)
      expect(Template.last.app_id).to eq(id)
      expect(Template.last.app_name).to eq(nme)
    end
  end

  describe 'append a block' do
    before(:all) do
      Template.create!(app_id:2,app_name:'Append block test')
    end
    it 'should append a block to the template' do
      @bb = Block.create( template_id:Template.last.id,block:['BEGIN Append block test','END'] )
      @bb.save
      expect(@bb.is_a?(Block)).to be_truthy
    end
    it 'should receive a block id' do
      pp Block.last
      expect(Block.last.id.is_a?(Fixnum)).to be_truthy
    end
  end

  describe 'insert a block' do
    before(:all) do
      Template.create(app_id:2,app_name:'Insert block test')
      5.times{|i|
        Block.create( template_id:Template.last.id,block:["BEGIN Insert block test #{i}",'END'] )
      }
      Block.create( template_id:Template.last.id,block:['BEGIN Insert block test X','END'],seq_id:3 )
      pp Block.all
    end
    it 'should insert a block at specified index' do
      expect(Block.last.name).to eq('Insert block test X')
      expect(Block.last.seq_id).to eq(3)
    end
    it 'should update seq ids of following blocks' do
      expect(Block.find(3).seq_id).to eq(4)
      expect(Block.find(4).seq_id).to eq(5)
    end

  end

  describe 'delete a block' do
    it 'should delete block from template'
    it 'should resequence all blocks'
  end

  describe 'block iterator' do
    it 'should have an each to iterate blocks'
  end

  describe 'searching blocks' do
    it 'should search by name'
    it 'should return an array of blocks'
  end

  describe 'importing template' do
    it 'should have a file name'
    it 'should have an application id and description'
    it 'should add an entry to template table and return id'
    it 'should parse blocks'
  end

  describe 'exporting template' do
    it 'should write a new text file template'
  end

  describe 'deleting template' do
    it 'should delete template entry'
    it 'all related blocks should be removed'
  end

end
