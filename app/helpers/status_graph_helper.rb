module StatusGraphHelper

  def bar_graph(percentage=0, activity = false, _classes = nil)
    classes = _classes || ['progress']
    classes << 'activity' if activity
    classes << 'completed' if (percentage > 99.992)

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
