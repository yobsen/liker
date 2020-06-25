# frozen_string_literal: true

require 'active_record'

class Track < ActiveRecord::Base
  def self.upsert(artist, track, found_by_track = false, found_by_artist = false)
    track = Track.where(
      artist: artist,
      track: track,
      found_by_track: found_by_track,
      found_by_artist: found_by_artist
    ).first_or_initialize
    track.save!
  end
end
