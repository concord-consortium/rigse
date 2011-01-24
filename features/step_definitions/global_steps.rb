Given /^there are (\d+) (.+)$/ do |number, model_name|
  model_name = model_name.gsub(/\s/, '_').singularize
  the_class = model_name.classify.constantize
  
  the_class.destroy_all
  number.to_i.times do |i|
    Factory.create(model_name.to_sym)
  end
end