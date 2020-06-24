class AddDefaultValuesForFoundByFields < ActiveRecord::Migration[6.0]
  def change
    change_column_default(:tracks, :found_by_track, false)
    change_column_default(:tracks, :found_by_artist, false)
  end
end
