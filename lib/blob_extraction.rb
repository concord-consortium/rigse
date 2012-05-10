module BlobExtraction
  URL_RESOLVER = URLResolver.new
  BLOB_CONTENT_REGEXP = /\s*gzb64:([^<]+)/m
  BLOB_URL_REGEXP = /(?:http.*?\/dataservice|\.\.)\/blobs\/([0-9]+)\.blob\/([0-9a-zA-Z]+)/

  def extract_blobs(host = nil)
    return false if ! self.otml
    changed = false

    if ! host
      address = URI.parse(APP_CONFIG[:site_url])
      host = address.host
    end

    text = self.otml

    # first find all the previously processed blobs, and re-point their urls
    begin
      text.gsub!(BLOB_URL_REGEXP) {|match|
        changed = true
        match = URL_RESOLVER.getUrl("dataservice_blob_raw_url", {:id => $1, :token => $2, :host => host, :format => "blob", :only_path => false})
        match
      }
    rescue Exception => e
      $stderr.puts "#{e}: #{$&}"
    end

    begin
      # find all the unprocessed blobs, and extract them and create Blob objects for them
      text.gsub!(BLOB_CONTENT_REGEXP) {|match|
        changed = true
        _content = B64Gzip.unpack($1.gsub!(/\s/, ""))
        # the following find is probably of limited use, and is expensive:
        # blob = Dataservice::Blob.find_or_create_by_bundle_content_id_and_content(self.id, B64Gzip.unpack($1.gsub!(/\s/, "")))

        # sometimes we don't have a valid id, but thats OK, we build our list here:
        blob = Dataservice::Blob.create(:content => _content)
        self.blobs << blob
        match = URL_RESOLVER.getUrl("dataservice_blob_raw_url", {:id => blob.id, :token => blob.token, :host => host, :format => "blob", :only_path => false})
        match
      }
    rescue Exception => e
      $stderr.puts "#{e}: #{$&}"
    end

    self.otml = text if changed

    return changed
  end
end
