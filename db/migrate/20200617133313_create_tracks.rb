class CreateTracks < ActiveRecord::Migration[6.0]
  def change
    create_table :tracks do |t|
      t.string :artist
      t.string :track
      t.boolean :found_by_track, default: false
      t.boolean :found_by_artist, default: false

      t.timestamps
    end
  end
end
