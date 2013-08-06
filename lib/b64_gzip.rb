class B64Gzip
  def self.unpack(b64gzip_content)
    s = StringIO.new(B64::B64.decode(b64gzip_content))
    z = ::Zlib::GzipReader.new(s)
    return z.read
  end

  def self.pack(content)
    gzip_string_io = StringIO.new()
    gzip = Zlib::GzipWriter.new(gzip_string_io)

    # use a fixed modified time so b64gzip_pack always returns the same string with the same input
    #  the gzip spec (http://www.gzip.org/zlib/rfc-gzip.html) says when gzipping a string mtime defaults to the current time
    #  so if mtime isn't fixed then calls to this method will return different strings depending when it is called
    gzip.mtime=1
    gzip.write(content)
    gzip.close
    gzip_string_io.rewind
    return B64::B64.encode(gzip_string_io.string)
  end
end
