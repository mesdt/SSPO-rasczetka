class GuidesNonNullable < ActiveRecord::Migration
  def change
  	 change_column_null(:trips, :guide_id, false)
  end
end
