require 'watir'

Watir.default_timeout = 600

class TrackList

  def initialize(audios_root)
    @audios_root = audios_root
    @track_list = []
  end

  def browser
    switches = %W[--user-data-dir=/home/manya/.config/google-chrome]

    @browser ||= Watir::Browser.new :chrome, switches: switches
  end

  def fetch_tracks_from_root
    browser.goto(@audios_root)

    authorize_to_vk

    track_nodes = browser.divs(class: 'audio_row__inner')
    track_nodes.each do |track_node|
      track_author = browser.div(class: 'audio_row__performers').link.text
      track_name = browser.div(class: 'audio_row__title').span(class: 'audio_row__title_inner').text 
      track = "#{track_author} #{track_name}"
      @track_list.push(track)
    end
  end

  def add_tracks_to_favorite
    browser.goto('https://music.youtube.com/search?q=l')
    browser.div(class: 'search-box').text_field(class: 'ytmusic-search-box').set "placebo meds"
    browser.send_keys :enter

    sleep 1

    songs_button = browser.link(class: ['yt-simple-endpoint', 'style-scope', 'ytmusic-chip-cloud-chip-renderer'])

    if songs_button.title == 'Show song results'
      songs_button.click
    end

    song = browser.elements(tag_name: 'ytmusic-responsive-list-item-renderer', class: ['style-scope', 'ytmusic-shelf-renderer']).to_a[0]
    song.hover

    song_menu_button = song.element(tag_name: 'ytmusic-menu-renderer', class: ['menu', 'style-scope', 'ytmusic-responsive-list-item-renderer'])
    song_menu_button.click

    song_menu = browser.element(tag_name: 'paper-listbox', class: ['style-scope', 'ytmusic-menu-popup-renderer'], role: 'listbox')
    like_button = song_menu.elements(tag_name: 'ytmusic-toggle-menu-service-item-renderer', class: ['ytmusic-menu-popup-renderer']).to_a[1]

    if like_button.element(tag_name: 'yt-formatted-string').text == 'Add to liked songs'
      like_button.click
    end  
  end
end

test = TrackList.new('https://vk.com/audios339740727')
# test.fetch_tracks_from_root
test.add_tracks_to_favorite
