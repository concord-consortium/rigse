module DrawToolHelper

  def dt_pallet_image
    "/images/otrunk_objects/draw_tool.gif";
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
    return <<-DONE
      background-image:   url('#{dt_pallet_image}');
     display:             block; 
     width:               #{dt_pallet_image_width}px;
     height:              #{dt_pallet_image_height}px;}
     DONE
  end
  
  def dt_canvas_style(draw_tool)
    return <<-DONE
    background-image:      url('#{draw_tool.background_image_url}');
    background-repeat:     no-repeat;
    background-position:   top-left;
    overflow:              hidden; 
    display:               block; 
    width:                 #{dt_canvas_width}px; 
    height:                #{dt_canvas_height}px;}
    DONE
  end
end
