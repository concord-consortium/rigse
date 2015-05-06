# A sample Guardfile
# More info at https://github.com/guard/guard#readme

at_exit { `spring stop` }

guard :cucumber,
  command_prefix: 'spring',
  bundler: false,
  keep_failed: false,
  all_after_pass: false,
  all_on_start: false    do
    watch(%r{^features/.+\.feature$})
    # watch(%r{^features/step_definitions/(.+)_steps\.rb$}) { |m| Dir[File.join("**/#{m[1]}.feature")][0] || 'features' }
end

guard :rspec,
  spring: true,
  bundler: false,
  cli: "--color --format nested --fail-fast --drb",
  failed_mode: :none,
  all_after_pass: false,
  all_on_start: false    do
    watch(%r{^spec/.+_spec\.rb$})
    watch(%r{^lib/(.+)\.rb$})     { |m| "spec/libs/#{m[1]}_spec.rb" }
    # watch('spec/spec_helper.rb')  { "spec" }
    # watch(%r{^spec/support/(.+)\.rb$})                  { "spec" }

    # Rails example
    watch(%r{^app/(.+)\.rb$})                           { |m| "spec/#{m[1]}_spec.rb" }
    watch(%r{^app/(.*)(\.erb|\.haml)$})                 { |m| "spec/#{m[1]}#{m[2]}_spec.rb" }
    watch(%r{^app/controllers/(.+)_(controller)\.rb$})  { |m| ["spec/routing/#{m[1]}_routing_spec.rb", "spec/#{m[2]}s/#{m[1]}_#{m[2]}_spec.rb", "spec/acceptance/#{m[1]}_spec.rb"] }
    watch('config/routes.rb')                           { "spec/routing" }
    watch('app/controllers/application_controller.rb')  { "spec/controllers" }

    # Capybara features specs
    watch(%r{^app/views/(.+)/.*\.(erb|haml)$})          { |m| "spec/features/#{m[1]}_spec.rb" }
end

