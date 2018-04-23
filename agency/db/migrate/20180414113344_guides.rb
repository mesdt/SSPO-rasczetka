class Guides < ActiveRecord::Migration
  def change
  	  add_reference :trips, :guide, index: true
  end
end
