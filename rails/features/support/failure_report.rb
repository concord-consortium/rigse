# CI's progress formatter never prints a failed hook's error (and pretty misattributes it), so print every failure here.
InstallPlugin do |config, _registry|
  test_case = nil
  config.on_event(:test_case_started) { |event| test_case = event.test_case }
  config.on_event(:test_step_finished) do |event|
    next unless event.result.failed?

    step = event.test_step
    error = event.result.exception
    kind = step.hook? ? 'hook' : 'step'
    $stdout.puts "\nFAILED #{kind} in \"#{test_case.name}\" (#{test_case.location})"
    $stdout.puts "  #{kind}: #{step.text} (#{step.location})"
    $stdout.puts "  #{error.class}: #{error.message}"
    (error.backtrace || []).each { |line| $stdout.puts "    #{line}" }
    $stdout.flush
  end
end
