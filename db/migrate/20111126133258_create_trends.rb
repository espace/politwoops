class CreateTrends < ActiveRecord::Migration
  def self.up
    create_table :trends do |t|
      t.integer :year
      t.integer :month
      t.string :name
      t.text :value

      t.timestamps
    end
  end

  def self.down
    drop_table :trends
  end
end