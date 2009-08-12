module B64
  class B64
    def self.folding_encode(str, eol = "\n", limit = 60)
      [str].pack('m')
    end

    def self.encode(str)
      [str].pack('m').tr( "\r\n", '')
    end

    def self.decode(str, strict = false)
      str.unpack('m').first
    end
  end
end
