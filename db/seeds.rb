teacher = User.new
["red", "orange", "yellow", "green"].each do |color|
  clazz = Portal::Clazz.create(:name => color, :class_word => color)
end
