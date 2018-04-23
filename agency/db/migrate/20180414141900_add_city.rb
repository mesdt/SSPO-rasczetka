class AddCity < ActiveRecord::Migration
  def change
  	 add_reference :trips, :city, index: true
  	 change_column_null(:trips, :city_id, false)
  end
end
