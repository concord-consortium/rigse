Around('@lightweight') do |scenario, block|
  @default_use_jnlps = APP_CONFIG[:use_jnlps]
  APP_CONFIG[:use_jnlps] = false  
  block.call
  APP_CONFIG[:use_jnlps] = @default_use_jnlps
end

Around('@use_gse') do |scenario, block|
  @default_use_gse = APP_CONFIG[:use_gse]
  APP_CONFIG[:use_gse] = true
  block.call
  APP_CONFIG[:use_gse] = @default_use_jnlps
end