module StatusGraphHelper

  def bar_graph(percentage, activity = false, _classes = nil) 
    classes = _classes || ['progress']
    classes << 'activity' if activity
    classes << 'complete' if (percentage == 100)
    
    classes_str = classes.join(' ')
    
    capture_haml do
      haml_tag :div, :class => 'progressbar_container' do
        haml_tag :div, :class => 'progressbar' do
          haml_tag :div, :class => classes_str, :style => "width:#{percentage}%"
        end
      end
    end
  end

end