class ImageDimension
  FormatString = "%{width}x%{height} (%{size})"

  def initialize(image, style= :original)
    @image = image
    @style = @style
    width = height = size = 0
    begin
      dims   = Paperclip::Geometry.from_file(self.path)
      width  = dims.width  || 0
      height = dims.height || 0
      size   = image.size  || 0
    rescue Error => e
      Rails.log("Unexpected error in image.rb:  #{e}")
    end
    @formatted_string = FormatString % {
      :width  => width.round,
      :height => height.round,
      :size   => size.round
    }
  end

  def to_s
    @formatted_string
  end

  protected
  def path
    self.use_s3? ? @image.url(@style) : @image.path(@style)
  end

  def use_s3?
    @image.options[:storage] == :s3
  end
end