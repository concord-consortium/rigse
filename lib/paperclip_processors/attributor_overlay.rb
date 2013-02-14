class AttributorOverlay < Paperclip::Processor
  def initialize(file, options = {}, attachment = nil)
    @file = file
    @target_geometry = (options[:geometry] && options[:geometry] !~ /#/) ? Paperclip::Geometry.parse(options[:geometry]) : Paperclip::Geometry.from_file(@file)
    @whiny = options[:whiny].nil? ? true : options[:whiny]
    @attach = attachment.instance
    @attribution = @attach.attribution.dup || " "


    if (@attach.respond_to? :uploaded_by_attribution)
      @attribution << "\n" unless @attribution.blank?
      @attribution << @attach.uploaded_by_attribution
    end

    @current_format = File.extname(@file.path)
    @basename =  File.basename(@file.path, @current_format)
    @source_geometry = Paperclip::Geometry.from_file(@file)
    @width = @source_geometry.width
    @height = @source_geometry.height

    # calculate the scaling require to fit the image into the target_geometry
    wRatio = @width / @target_geometry.width.to_f
    hRatio = @height / @target_geometry.height.to_f

    @scale = ((wRatio > hRatio) ? wRatio : hRatio)
  end

  def make
    wm_dst = make_watermark

    dst = Tempfile.new(@basename)
    dst.binmode

    composite_params = "-dissolve 60 -gravity South #{tofile(wm_dst)} #{fromfile} #{tofile(dst)}"

    begin
      success = Paperclip.run("composite", composite_params)
    rescue Paperclip::Error => e
      raise Paperclip::Error, "There was an error adding attribution to #{@basename}: #{e}" if @whiny
    end

    dst
  end

  def make_watermark
    wm_dst = Tempfile.new("#{@basename}-watermark")
    wm_dst.binmode

    border = 3
    pointsize = 14

    # scale the text since most images will be displayed at around screen size
    pointsize = (pointsize*@scale).ceil
    pointsize = 10 if pointsize < 10

    watermark_params = %!-background white -fill black -border #{border} -bordercolor white -pointsize #{pointsize} -size #{(@width-(2*border)).to_i}x -gravity SouthEast caption:"#{escape(@attribution)}" png:#{tofile(wm_dst)}!

    begin
      success = Paperclip.run("convert", watermark_params)
    rescue Paperclip::Error => e
      raise Paperclip::Error, "There was an error adding attribution to #{@basename}: #{e}" if @whiny
    end

    wm_dst
  end

  def fromfile
    %!"#{ File.expand_path(@file.path) }[0]"!
  end

  def tofile(destination)
    %!"#{ File.expand_path(destination.path) }[0]"!
  end

  def escape(str = " ")
    str = " " if str.nil? || str.empty?
    str.gsub(/"/, %q!\"!).gsub(/\$/, %q!\$!)
  end
end
