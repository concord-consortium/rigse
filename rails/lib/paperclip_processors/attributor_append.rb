require 'attributor_overlay'
class AttributorAppend < AttributorOverlay
  def make
    wm_dst = make_watermark

    dst = Tempfile.new(@basename)
    dst.binmode

    composite_params = "#{fromfile} #{tofile(wm_dst)} -append #{tofile(dst)}"

    begin
      success = Paperclip.run("convert", composite_params)
    rescue Paperclip::Error => e
      raise Paperclip::Error, "There was an error adding attribution to #{@basename}: #{e}" if @whiny
    end

    dst
  end
end