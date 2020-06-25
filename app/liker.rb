require 'dotenv/load'
require 'watir'
require 'active_record'
require_relative 'app/models/track'

Watir.default_timeout = 600

def db_configuration
  db_configuration_file = File.join(File.expand_path(__dir__), 'db', 'config.yml')
  YAML.safe_load(File.read(db_configuration_file))
end

ActiveRecord::Base.establish_connection(db_configuration['development'])

class Liker
  def self.start(vk_root)
    liker = Liker.new(vk_root)
    liker.fetch_tracks_from_root
    liker.add_tracks_to_favorite
  end

  def initialize(audios_root)
    @audios_root = audios_root
  end

  def browser
    switches = %W[--user-data-dir=#{ENV['CHROME_PROFILE_PATH']}]
    @browser ||= Watir::Browser.new :chrome, switches: switches
  end

  def fetch_tracks_from_root
    browser.goto(@audios_root)
    1000.times { browser.scroll.to :bottom }

    track_nodes = browser.divs(class: 'audio_row__inner')
    track_nodes.each do |track_node|
      track_author = track_node.div(class: 'audio_row__performers').link.text
      track_name = track_node.div(class: 'audio_row__title').span(class: 'audio_row__title_inner').text 

      Track.upsert(track_author, track_name)
    end
  end

  def check_artist_and_track_name(track)
    founded_artist = browser.divs(class: 'secondary-flex-columns').to_a[0].links(class: 'yt-simple-endpoint').to_a[0].text.downcase
    founded_track_name = browser.divs(class: 'title-column').to_a[0].text.downcase 
    if founded_artist == track.artist.downcase
      track.found_by_artist = true
    elsif founded_track_name == track.track.downcase
      track.found_by_track = true
    end

    return track
  end

  def is_track_info_correct(track)
    track.found_by_artist == true || track.found_by_track == true
  end

  def scraping_error(error)
    puts "error: #{error.class} occured"
    binding.pry
  end

  def allocate_like_button
    songs_button = browser.link(class: ['yt-simple-endpoint', 'style-scope', 'ytmusic-chip-cloud-chip-renderer'])
    if songs_button.title == 'Show song results'
      songs_button.click
    else 
      browser&.close
      binding.pry
    end

    sleep 10

    song = browser.elements(tag_name: 'ytmusic-responsive-list-item-renderer', class: ['style-scope', 'ytmusic-shelf-renderer']).to_a[0]
    song.hover

    song_menu_button = song.element(tag_name: 'ytmusic-menu-renderer', class: ['menu', 'style-scope', 'ytmusic-responsive-list-item-renderer'])
    song_menu_button.click

    sleep 5
  end

  def add_tracks_to_favorite
    browser.goto('https://music.youtube.com/search?q=l')
    Track.all.each do |track|
      if track.found_by_track == true || track.found_by_artist == true
        next
      end

      browser.div(class: 'search-box').text_field(class: 'ytmusic-search-box').set "#{track.artist} #{track.track}"
      browser.send_keys :enter
      sleep 10

      allocate_like_button

      song_menu = browser.element(tag_name: 'paper-listbox', class: ['style-scope', 'ytmusic-menu-popup-renderer'], role: 'listbox')
      like_button = song_menu.elements(tag_name: 'ytmusic-toggle-menu-service-item-renderer', class: ['ytmusic-menu-popup-renderer']).to_a[1]

      checked_track = check_artist_and_track_name(track)

      if is_track_info_correct(track) && like_button.element(tag_name: 'yt-formatted-string').text == 'Add to liked songs'
        like_button.click

        track.found_by_artist = checked_track.found_by_artist
        track.found_by_track = checked_track.found_by_track
        track.save!

        puts "track (#{track.artist} - #{track.track}) was successfully liked"
        next
      else
        puts "Track info (#{track.artist} - #{track.track}) is incorrect or you have already liked it"
        next
      end  
    end

  rescue StandardError => e
    scraping_error(e)
  end
end

test = Liker.start(ENV['VK_PLAYLIST_PATH'])
