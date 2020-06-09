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
    browser.text_field(class: 'ytmusic-search-box').set "placebo meds"
    browser.send_keys :enter
  end
end

test = TrackList.new('https://vk.com/audios339740727')
# test.fetch_tracks_from_root
test.add_tracks_to_favorite
