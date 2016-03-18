module FirstLogicTemplate
  require 'spec_helper'

  def append_blk(o,b)
    parm,arg = B.parse(o)
    @ii = Block.create( parm:parm,arg:arg,block_id:b )
  end

  describe 'creating a template' do
    it 'should fail without any params' do
      expect{Template.create()}.to raise_error(ArgumentError)
    end
    it 'should fail without an app_name' do
      expect{Template.create(app_id:1)}.to raise_error(ArgumentError)
    end
    it 'should have an application id' do
      expect{Template.create(app_name:'Test Template')}.to raise_error(ArgumentError)
    end
    it 'should add an entry to template table and return id' do
      id = 1; nme = 'Create template'
      @tt = Template.create(app_id:id,app_name:nme)
      expect(@tt.is_a?(Template)).to be_truthy
      expect(@tt.app_id).to eq(1)
      expect(@tt.app_name).to eq(nme)
    end
  end

  describe 'append a block' do
    before(:all) do
      @tt = Template.create(app_id:2,app_name:'Append block')
    end
    it 'should tell block to append array of instructions as block' do
      @bb = Block(blk:['BEGIN','END'])
    end
    it 'should receive a block id'
  end

  describe 'insert a block' do
    it 'should insert a block at specified index'
    it 'should update seq ids of following blocks'
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
