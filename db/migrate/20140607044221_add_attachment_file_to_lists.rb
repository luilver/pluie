class AddAttachmentFileToLists < ActiveRecord::Migration
  def self.up
    change_table :lists do |t|
      t.attachment :file
    end
  end

  def self.down
    drop_attached_file :lists, :file
  end
end
