#TODO: move me out of here?
require 'fakeweb'
@video_url = "http://example.com/small_image.jpg"
FakeWeb.register_uri(:head, @video_url, :status => ["200", "OK"],:content_type => "video/flv", :content_length => 100)

Factory.define :video_player, :class => Embeddable::VideoPlayer do |f|
  f.description  "a video clip of a volcano"
  f.video_url  @video_url
  f.name  "video clip"
end

