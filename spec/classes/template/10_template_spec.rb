module FirstLogicTemplate
  require 'spec_helper'

  describe 'template' do
    it 'should receive a connection'
    it 'should be responsible for migrating db if it does not exist'
  end

  describe 'creating a template' do
    it 'should have a description'
    it 'should have an application id and description'
    it 'should add an entry to template table and return id'
  end

  describe 'append a block' do
    it 'should tell block to append array of instructions as block'
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
