Around('@lightweight') do |scenario, block|
  APP_CONFIG[:use_jnlps] = false  
  block.call
  APP_CONFIG[:use_jnlps] = @default_use_jnlps
end