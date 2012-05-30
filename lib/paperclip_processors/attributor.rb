module Paperclip
  class AttributorOverlay < Processor
    def initialize(file, options = {}, attachment = nil)
      @file = file
      @whiny = options[:whiny].nil? ? true : options[:whiny]
      @attach = attachment.instance
      @attribution = @attach.attribution
      @current_format = File.extname(@file.path)
      @basename =  File.basename(@file.path, @current_format)
      dims = Paperclip::Geometry.from_file(@file)
      @width = dims.width
      @height = dims.height
    end

    def make
      wm_dst = make_watermark

      dst = Tempfile.new(@basename)
      dst.binmode

      composite_params = "-dissolve 60 -gravity South #{tofile(wm_dst)} #{fromfile} #{tofile(dst)}"

      begin
        success = Paperclip.run("composite", composite_params)
      rescue PaperclipCommandLineError => e
        raise PaperclipError, "There was an error adding attribution to #{@basename}: #{e}" if @whiny
      end

      dst
    end

    def make_watermark
      wm_dst = Tempfile.new("#{@basename}-watermark")
      wm_dst.binmode

      border = 3
      pointsize = 14

      # scale the text since most images will be displayed at around screen size
      scale = @width/650.0
      pointsize = (pointsize*scale).ceil
      pointsize = 10 if pointsize < 10

      watermark_params = %!-background white -fill black -font Arial -border #{border} -bordercolor white -pointsize #{pointsize} -size #{(@width-(2*border)).to_i}x -gravity SouthEast caption:"#{escape(@attribution)}" png:#{tofile(wm_dst)}!

      begin
        success = Paperclip.run("convert", watermark_params)
      rescue PaperclipCommandLineError => e
        raise PaperclipError, "There was an error adding attribution to #{@basename}: #{e}" if @whiny
      end

      wm_dst
    end

    def fromfile
      %!"#{ File.expand_path(@file.path) }[0]"!
    end

    def tofile(destination)
      %!"#{ File.expand_path(destination.path) }[0]"!
    end

    def escape(str = "")
      str = "" if str.nil?
      str.gsub(/"/, %q!\"!).gsub(/\$/, %q!\$!)
    end
  end

  class AttributorAppend < AttributorOverlay
    def make
      wm_dst = make_watermark

      dst = Tempfile.new(@basename)
      dst.binmode

      composite_params = "#{fromfile} #{tofile(wm_dst)} -append #{tofile(dst)}"

      begin
        success = Paperclip.run("convert", composite_params)
      rescue PaperclipCommandLineError => e
        raise PaperclipError, "There was an error adding attribution to #{@basename}: #{e}" if @whiny
      end

      dst
    end
  end
end
