class CreateEventImages < ActiveRecord::Migration
  def self.up
    create_table :event_images, :force => true do |t|
      t.string :image
      t.integer :organization_id

      t.timestamps
    end
  end

  def self.down
    drop_table :event_images
  end
end
