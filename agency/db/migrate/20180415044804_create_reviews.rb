class CreateReviews < ActiveRecord::Migration
  def change
    create_table :reviews do |t|
      t.references :trip, index: true, foreign_key: true
      t.string :name
      t.string :text

      t.timestamps null: false
    end
  end
end
