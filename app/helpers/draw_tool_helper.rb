module DrawToolHelper

  def dt_pallet_image
    image_path("otrunk_objects/draw_tool.gif");
  end
  
  def dt_padding
    40
  end
  def dt_pallet_image_width
    624
  end
  
  def dt_pallet_image_height
    223
  end
  
  def dt_canvas_width
    592
  end

  def dt_canvas_height
    185
  end
  
  def dt_pallet_style
    style = <<-DONE
     background-image:      url('#{dt_pallet_image}');
     background-position:   bottom right;
     background-repeat:     no-repeat;
     display:               block; 
     overflow:              hidden;
     width:                 100% !important;
     min-height:            #{dt_pallet_image_height}px;
     DONE
    style.gsub(/\s+/, " ").gsub(/$/, " ")
  end
  
  def dt_mask_style
    style = <<-DONE
     display:               block; 
     overflow:              hidden;
     display:  block;
     position: relative;
     margin-bottom:         #{dt_padding}px;
     margin-right:          #{dt_padding}px;
     width:                 90%;
     DONE
    style.gsub(/\s+/, " ").gsub(/$/, " ")
  end
  
  def dt_image_style
    style = <<-DONE
     border:                2px grey solid;
     display:               block;
     position:              absolute;
     left:                  0;
     bottom: 0;
     DONE
    style.gsub(/\s+/, " ").gsub(/$/, " ")
  end

end
