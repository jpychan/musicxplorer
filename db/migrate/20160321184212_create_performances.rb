class CreatePerformances < ActiveRecord::Migration
  def change
    create_table :performances do |t|
      t.references :festival
      t.references :artist
      t.timestamps null: false
    end
  end
end
