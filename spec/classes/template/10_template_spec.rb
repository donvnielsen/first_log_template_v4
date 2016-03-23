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
      Block.create( template_id:Template.last.id,block:['BEGIN Append block test','END'] )
      b = Block.find_by template_id:Template.last.id
      expect(b.seq_id).to eq(1)
    end
  end

  describe 'insert a block' do
    before(:all) do
      Template.create(app_id:3,app_name:'Insert block test')
      5.times{|i|
        Block.create( template_id:Template.last.id,block:["BEGIN Insert block test #{i+1}",'END'] )
      }
      Block.create( template_id:Template.last.id,block:['BEGIN Insert block test X','END'],seq_id:3 )
    end
    it 'should insert a block at specified index' do
      expect(Block.last.name).to eq('Insert block test X')
      expect(Block.last.seq_id).to eq(3)
    end
    it 'should update seq ids of following blocks' do
      [
          [3,'Insert block test X'],
          [4,'Insert block test 3'],
          [5,'Insert block test 4']
      ].each {|seq_id,name|
        b = Block.where('template_id = ? and seq_id = ?',Template.last.id,seq_id).first
        expect(b.name).to eq(name)
      }
    end

  end

  describe 'Deleting a block from many blocks' do
    before(:all) do
      Template.create(app_id:4,app_name:'Delete block test')
      10.times{|i|
        Block.create( template_id:Template.last.id,block:["BEGIN Delete block test #{i+1}",'END'] )
      }
    end
    context 'delete block #1 (first)' do
      before(:all) do
        Block.where('template_id = ? and seq_id = 1',Template.last.id).first.destroy
      end
      it 'should not find the block' do
        b = Block.where('template_id = ? and name = ?',Template.last.id,'Delete block test 1')
        expect(b.size).to eq(0)
      end
      it 'should resequence remaining blocks' do
        expect(Block.minimum(:seq_id)).to eq(1)
        expect(Block.maximum(:seq_id)).to eq(9)
        bb = Block.where('template_id = ?',Template.last.id)
        expect(bb.size).to eq(9)
        expect(bb.last.name).to eq('Delete block test 10')
      end
    end
    context 'delete block #5 (middle)' do
      before(:all) do
        Block.where('template_id = ? and seq_id = 5',Template.last.id).first.destroy
      end
      it 'should not find the block' do
        b = Block.where('template_id = ? and name = ?',Template.last.id,'Delete block test 6')
        expect(b.size).to eq(0)
      end
      it 'should resequence remaining blocks' do
        expect(Block.minimum(:seq_id)).to eq(1)
        expect(Block.maximum(:seq_id)).to eq(8)
        bb = Block.where('template_id = ?',Template.last.id)
        expect(bb.size).to eq(8)
        expect(bb.last.name).to eq('Delete block test 10')
      end
    end
    context 'delete block #8 (last)' do
      before(:all) do
        Block.where('template_id = ? and seq_id = 8',Template.last.id).first.destroy
      end
      it 'should not find the block' do
        b = Block.where('template_id = ? and name = ?',Template.last.id,'Delete block test 10')
        expect(b.size).to eq(0)
      end
      it 'should resequence remaining blocks' do
        expect(Block.minimum(:seq_id)).to eq(1)
        expect(Block.maximum(:seq_id)).to eq(7)
        bb = Block.where('template_id = ?',Template.last.id)
        expect(bb.size).to eq(7)
        expect(bb.last.name).to eq('Delete block test 9')
      end
    end
  end

  describe 'block iterator' do
    before(:all) do
      Template.create(app_id:2,app_name:'Block iterator test')
      5.times{|i|
        Block.create( template_id:Template.last.id,block:["BEGIN Block iterator test #{i+1}",'END'] )
      }
    end
    it 'should have an each to iterate blocks' do
      Template.last.each_with_index{|b,i|
        expect(b.is_a?(Block)).to be_truthy
        expect(b.name).to eq("Block iterator test #{i+1}")
      }
    end
  end

  describe 'searching blocks using tag(s)' do
    it 'should search with one tag'
    it 'should search with multiple tags'
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

  describe 'Delete template' do
    before(:all) do
      @t = Template.create(app_id:2,app_name:'Template delete test')
      5.times{|i|
        Block.create( template_id:Template.last.id,block:["BEGIN Template delete test #{i+1}",'END'] )
      }
    end
    it 'should delete all related data' do
      Template.last.delete
      expect{Template.find(@t.id)}.to raise_error(ActiveRecord::RecordNotFound)
      expect(Block.where('template_id = ?',@t.id).size).to eq(0)
    end
  end

end
