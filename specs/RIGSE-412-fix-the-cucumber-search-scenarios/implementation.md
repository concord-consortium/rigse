# Implementation Plan: Browser tests fail in teardown on Chrome 158

**Jira**: https://concord-consortium.atlassian.net/browse/RIGSE-412
**Requirements Spec**: [requirements.md](requirements.md)
**Status**: **In Development**

## Implementation Plan

Four commits, each independent of the ones after it. None touches `Gemfile`, `Gemfile.lock` or application code (R12). Commit subjects follow the repo's `<type>: <summary> (RIGSE-412)` form.

### Clear the test browser's cookies and local storage without the "*" origin

**Summary**: Fixes the teardown error on Chrome 158 for cucumber and RSpec system tests alike (R1 to R7), and adds the test that fails if the reset stops clearing cookies or local storage (R4). This is the commit that turns CI green.

**Files affected**:
- `rails/spec/support/capybara_chrome_reset.rb` (new): the workaround.
- `rails/spec/system/capybara_session_reset_spec.rb` (new): the test.

**Estimated diff size**: ~55 lines

`spec/support/**` is loaded by `spec/spec_helper_common.rb`, which both RSpec and `features/support/env.rb` require, so one file covers both. The file requires `capybara/selenium/driver` itself, because it does not depend on the load order of other support files. It stops the test run if the bundle's Capybara is not the version it was written against (see Open Questions). It overrides only the private `execute_cdp`, and only for the one call `ChromeDriver#reset!` makes with the `'*'` origin; every other CDP call passes through. `storageTypes` is always a string here (`storage_types_to_clear` joins with commas).

```ruby
# rails/spec/support/capybara_chrome_reset.rb
require 'capybara/selenium/driver'

# Capybara's ChromeDriver#reset! clears cookies and local storage with Storage.clearDataForOrigin
# for the origin "*", which Chrome 158 and later reject with "invalid argument: * is not a valid
# URL" (https://github.com/teamcapybara/capybara/issues/2865). This module replaces that call: it
# clears every cookie, then the local storage of each origin the tab visited.
module CapybaraChromeResetWithoutWildcardOrigin
  private

  def execute_cdp(cmd, params = {})
    return super unless cmd == 'Storage.clearDataForOrigin' && params[:origin] == '*'

    super('Network.clearBrowserCookies')
    return unless params[:storageTypes].split(',').include?('local_storage')

    history = super('Page.getNavigationHistory')
    origins = history['entries'].filter_map { |entry| http_origin(entry['url']) }.uniq
    origins.each { |origin| super(cmd, origin: origin, storageTypes: 'local_storage') }
  end

  def http_origin(url)
    uri = URI.parse(url)
    "#{uri.scheme}://#{uri.host}:#{uri.port}" if %w[http https].include?(uri.scheme) && uri.host
  rescue URI::InvalidURIError
    nil
  end
end

patched_version = Gem::Version.new('3.40.0')
bundled_version = Gem.loaded_specs['capybara'].version
unless bundled_version == patched_version
  raise "#{__FILE__} patches Capybara #{patched_version} but the bundle has #{bundled_version}. Delete it if " \
        'that release fixes teamcapybara/capybara#2865, otherwise check the patch still fits and update the version.'
end

Capybara::Selenium::Driver::ChromeDriver.prepend(CapybaraChromeResetWithoutWildcardOrigin)
```

```ruby
# rails/spec/system/capybara_session_reset_spec.rb
require 'spec_helper'

RSpec.describe 'Capybara session reset', type: :system do
  def cookie_names
    page.driver.browser.manage.all_cookies.map { |cookie| cookie[:name] }
  end

  it 'clears cookies and local storage between tests' do
    visit '/'
    page.driver.browser.manage.add_cookie(name: 'reset_probe', value: '1')
    page.execute_script("localStorage.setItem('reset_probe', '1')")
    expect(cookie_names).to include('reset_probe')
    expect(page.evaluate_script("localStorage.getItem('reset_probe')")).to eq('1')

    Capybara.reset_sessions!
    visit '/'

    expect(cookie_names).not_to include('reset_probe')
    expect(page.evaluate_script("localStorage.getItem('reset_probe')")).to be_nil
  end
end
```

The two `expect`s before the reset make the test unable to pass vacuously: if the cookie or value were never set, it fails there rather than passing the checks after the reset. It runs in `ci:spec_system_tests` (it is `type: :system`, which `spec_helper_common.rb` excludes unless `RUN_SYSTEM_TESTS=true`).

Both files ran in the CI-like Docker setup (see Verification):

| Run | Result |
|---|---|
| Chrome 158, with the workaround | 1 example, 0 failures |
| Chrome 157, with the workaround | 1 example, 0 failures |
| Chrome 158, without it | errors at `Capybara.reset_sessions!` with `InvalidArgumentError` |
| Chrome 157, without it | 1 example, 0 failures (Capybara's own clear) |
| Chrome 158, cookie clear removed | fails: `expected ["reset_probe"] not to include "reset_probe"` |
| Chrome 158, local-storage clear removed | fails: `expected: nil` |

---

### Print every failed cucumber step and hook with its backtrace

**Summary**: Makes a failure's error readable in the CI log under the right scenario (R8), including the After-hook failures the progress formatter drops. `ci.rake` keeps `--format progress`.

**Files affected**:
- `rails/features/support/failure_report.rb` (new)

**Estimated diff size**: ~20 lines

Cucumber loads every file in `features/support/` and runs `InstallPlugin` blocks after configuration, so this works for every cucumber run (CI and local) without touching `cucumber.yml` or `ci.rake`. It prints nothing unless a step or hook fails. `test_step.text` is the step's text, or `After hook` / `Before hook` for hooks; `test_step.location` is the step's feature line or the hook's definition (for Capybara's reset, `capybara-3.40.0/lib/capybara/cucumber.rb:10`).

```ruby
# rails/features/support/failure_report.rb

# Prints every failed step and hook with its scenario and full backtrace. The progress
# formatter that CI uses never prints a failed hook's error, and the pretty formatter can
# print it under the wrong scenario.
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
```

Run as throwaway code through `rake ci:cucumber_search` on Chrome 158 without the first step's workaround: 11 `FAILED hook` blocks, one per scenario whose reset failed (the 6 failing and the 5 undefined ones), each under its own scenario name and line, with the error and its full backtrace. On a failing step (`admin_configures_settings.feature:31`, which fails locally): `FAILED step in "Admin enables default class" (...:31)`, the step and its line `:36`, the expectation message and backtrace. No automated test: exercising it means running cucumber on a deliberately failing feature in a subprocess, which costs more than this 20-line listener. The verification below covers it.

---

### Give each test job its own screenshot artifact and let every suite finish

**Summary**: R9 and R11. With unique names, every failing job's screenshots upload (R10's step-failure screenshots already land in `tmp/capybara`, checked locally). With fail-fast off, one red suite no longer cancels the rest.

**Files affected**:
- `.github/workflows/ci.yml`

**Estimated diff size**: 2 lines

```diff
     strategy:
+      fail-fast: false
       matrix:
         include:
@@
         uses: actions/upload-artifact@v4
         if: failure()
         with:
-          name: capybara-screenshots
+          name: capybara-screenshots-${{ matrix.test_suite }}
           path: /home/runner/work/rigse/rigse/rails/tmp/capybara/**
```

`actionlint` 1.7.7 reports the same 12 pre-existing findings (old action versions, an undefined `steps.filter` output) on the file before and after this change, none on the changed lines.
---

### Install only the browser tooling the tests use

**Summary**: R13. CI removes the image's Google Chrome and installs a Chromium snapshot that no test runs, under comments that describe that setup as what the tests use. This leaves the runner image's Chromium (the browser the driver options name) and the matching ChromeDriver, and says so.

**Files affected**:
- `.github/workflows/ci.yml`

**Estimated diff size**: ~12 lines

```diff
-      # Install ChromeDriver (wiping out whatever version was previously installed on Actions Runner)
+      # The tests run the runner image's Chromium at /usr/bin/chromium (see
+      # rails/spec/support/capybara_initializer.rb). The image's Chromium and Google Chrome share a
+      # version branch, and this installs the ChromeDriver for that Google Chrome.
       - name: Install ChromeDriver
         uses: nanasess/setup-chromedriver@v2
-      # Remove existing Google Chrome as ChromeDriver will default to it (setup-chrome installs under /opt/hostedtoolcache/setup-chrome/)
-      - name: Remove Existing Google Chrome (so ChromeDriver doesn't use it instead of manually installed version)
-        run: sudo apt-get remove google-chrome-stable
-      # Install Google Chrome browser (that matches ChromeDriver version from previous Actions step)
-      - name: Install Google Chrome
-        id: install-chrome
-        uses: browser-actions/setup-chrome@v1
```

What runs is unchanged by this commit: the failing run's log shows `setup-chromedriver` reading the image's Google Chrome (`CHROME_VERSION=158`) and installing ChromeDriver 158.0.8127.36 into `/usr/local/bin` (ahead of `/usr/bin` on `PATH`), and every step then ran against the image's Chromium 158.0.8127.0 through it. That run removed Google Chrome only after `setup-chromedriver` had read its version; with the removal gone, the version is still there to read. Per actions/runner-images' `install-google-chrome.sh`, the image picks its Chromium snapshot from its Google Chrome's branch position, so the two share a major version and ChromeDriver matches both. Nothing else in the workflow refers to the removed step's `install-chrome` id. `actionlint` 1.7.7 reports the same 12 pre-existing findings with this and the previous step applied. Only CI can run this step for real: the branch's push run must show the cucumber and system jobs passing, and the `Install ChromeDriver` step printing a ChromeDriver whose major version matches the image's Chromium.

## Verification

Local, in a CI-like Docker setup (it does not need GitHub): a `ruby:3.2.11-bookworm` container with Node 18.18.0, the Chrome dependencies and `iproute2` (uuidtools shells out to `ip`), Chrome for Testing 157.0.8103.78 and 158.0.8127.36 with their ChromeDrivers, and a switch that links the chosen one at `/usr/bin/chromium` and `/usr/local/bin/chromedriver`. Run it in the network namespace of a `mariadb:10.10` container (the CI database config uses `127.0.0.1`) beside a `concordconsortium/docker-solr-portal` container (`TEST_SOLR_HOST`, `TEST_SOLR_PORT=8983`). Run the `ci.yml` setup steps (config copies, `db:create` through `db:feature_test:prepare`, `app:setup:create_default_data` for the cucumber and test environments, the react-components build, `assets:precompile`), then the rake tasks.

On Chrome 158 with all three commits:

- `rake ci:cucumber_search`: `11 scenarios (5 undefined, 6 passed)`, no `FAILED` block (R6).
- `rake ci:cucumber_javascript`: no `FAILED hook` block; the only failures are the local-baseline ones listed in the requirements (R7).
- `RAILS_ENV=test RUN_SYSTEM_TESTS=true rspec --tag type:system`: 64 examples, 0 failures (63 existing plus the new one) (R4, R7).

On Chrome 157, `ci:cucumber_search` and the system specs give the same results.

In CI: the branch's push run on the current runner image (Chrome 158) is green on all five test jobs and the other jobs (R6, R7, R11, R13). The PR is pushed only on Doug's word.

## Open Questions

### RESOLVED: Judgment call: what happens when the bundle leaves Capybara 3.40.0?
**Context**: The workaround should not outlive the bug, and should not run against Capybara internals it was not written for.
**Options considered**:
- A) Apply only when the bundle has exactly 3.40.0, and do nothing otherwise.
- B) Raise at load time when the bundle has any other version, with a message saying to delete the file if that release fixes #2865, or to recheck it and update the version.
- C) Always apply, and remove it by hand later.

**Decision**: B, changed from A in the stage 7 review (see Self-Review). A leaves the file as silent dead code after a fixed release, which nobody is prompted to delete. B makes the Capybara bump itself the reminder: every spec run stops with the message until the file is deleted or rechecked. C may override code that no longer matches. The version lives in one constant, `patched_version`, used by both the check and the message. Verified: with the constant set to `3.39.2`, loading the file raises `... patches Capybara 3.39.2 but the bundle has 3.40.0. Delete it if that release fixes teamcapybara/capybara#2865, ...`; with `3.40.0`, the reset spec and `admin_notices_spec.rb` pass (8 examples) and `ci:cucumber_search` passes on Chrome 158.

### RESOLVED: Judgment call: report failed steps too, or only failed hooks?
**Context**: Progress already lists failed steps in its `(::) failed steps (::)` section, by feature line but not scenario name.
**Options considered**:
- A) Report steps and hooks, in one format.
- B) Report hooks only.

**Decision**: A. One searchable `FAILED` format for every failure, with the scenario's name, is worth the duplicate entry for step failures. Step failures are few in a run.

### RESOLVED: Judgment call: test the reset as a system spec, or as a plain spec with its own Rack app?
**Context**: R4's test needs a real browser.
**Options considered**:
- A) A `type: :system` spec against the app (runs in `ci:spec_system_tests` with the `headless_chrome` driver).
- B) A plain RSpec spec that builds its own `Capybara::Session` with a Rack app.

**Decision**: A. It uses the same driver setup and job the other browser specs use, needs no second driver definition, and was verified against both Chrome versions and both mutations. B worked as the throwaway probe but would be a browser test that `ci:spec_without_webdriver` also tries to run, needing a tag to exclude it.

## Self-Review

Roles: Commit Reviewer, Test Writer, Senior Engineer (Ruby and Capybara), Operator (CI and release).

### Operator

#### RESOLVED: The exact-version gate would leave dead code behind
As first written, the workaround did nothing on any Capybara other than 3.40.0. After a bump to a release that fixes #2865, the file would stay in `spec/support/` doing nothing, with only its comment asking for deletion. Fixed in place: the file now raises on any other version with a message naming both outcomes (decision B above), verified both ways.

### Senior Engineer

#### RESOLVED: "3.40.0" was written twice in the workaround
The version appeared in the comparison and again in the error message, and the header comment named it a third time. Fixed in place: one `patched_version` constant feeds the check and the message, and the comment no longer names a version.

### Test Writer

No findings. Checked: the reset spec's pre-reset expectations stop it from passing when the probe was never set; its four outcomes (fix on 157 and 158, no fix on 158, each half of the fix removed) were run; it runs in `ci:spec_system_tests`, whose `create_default_data` step provides the home page it visits. Rails system-test failure screenshots go to `Capybara.save_path` (`ActionDispatch::SystemTesting::TestHelpers::ScreenshotHelper#screenshots_dir`), so they also land under `tmp/capybara` and in that job's artifact.

### Commit Reviewer

No findings. Each commit stands alone: the first turns CI green with nothing after it; the listener and the two workflow edits depend on nothing in the others. The two workflow commits touch different lines of `ci.yml`. The plan's three files were checked byte for byte against the files run in the verification (`spec/support/capybara_chrome_reset.rb`, the reset spec, and `features/support/failure_report.rb` plus its path comment line).
