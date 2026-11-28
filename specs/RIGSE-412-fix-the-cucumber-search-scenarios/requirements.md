# Browser tests fail in teardown on Chrome 158

**Jira**: https://concord-consortium.atlassian.net/browse/RIGSE-412
**Repo**: https://github.com/concord-consortium/rigse
**Implementation Spec**: [implementation.md](implementation.md)
**Status**: **In Development**

## Overview

Every portal test that drives Chrome now fails on Chrome 158, after its steps pass, because the test library's session reset sends Chrome a request that Chrome 158 rejects. This story makes that reset work on Chrome 158 and later without pinning Chrome, and makes the next CI failure of this kind readable from the CI log and artifacts.

## Project Owner Overview

The portal's CI has been red since GitHub's runners moved to Chrome 158, so no run, including the production tag for release 2.32.0 (RIGSE-411), can pass. The six search scenarios named in the story are the visible part. The same fault breaks the other two browser suites, the JavaScript cucumber scenarios and the Rails system tests, but CI canceled them before they finished, which hid it. The application is not at fault: the problem is in Capybara, the library that drives the browser in tests, and it is a known, unfixed upstream bug.

The fix is a small, clearly marked workaround in the test setup, which asks to be deleted when the project moves to a new Capybara version, plus three changes to how CI reports failures: cucumber prints the error for every failure, each test job's screenshots get their own artifact, and one failing suite no longer cancels the others. CI also stops installing a second browser that no test uses, so its setup says plainly which Chrome the tests run. Nothing changes for portal users.

## Background

### What failed

Tag `v2.32.0-pre.0`'s CI run 46137620506 failed six scenarios in the `cucumber_search` job, on attempt 1 and on a rerun of failed jobs. Master's run 45488105226 passed every job on the same commit four days earlier. The log printed no errors, only the "Failing Scenarios" list, and the `capybara-screenshots` artifact held none of the six.

The story text puts the difference down to Chrome and ChromeDriver moving from 157.0.8103.78 to 158.0.8127.36, with the runner image unchanged. Reading both job logs shows the runner image did change (ubuntu-26.04 `20261116.202.1` on the passing run, `20261122.9.1` on the failing one), and that the browser the tests run is the runner image's own Chromium, not the one CI installs (see Technical Notes). That image's Chromium moved from 157.0.8103.0 to 158.0.8127.0, so the version change the story names is the right one, reached by a different route.

### Root cause (reproduced locally)

In the failing run, every step passed. Both runs report the same step totals, `203 steps (57 skipped, 7 undefined, 139 passed)`. So each scenario failed in a hook after its last step, and the "F" at the end of each scenario in the progress output is that hook.

Reproduced in a CI-like Docker setup (Ruby 3.2.11, Node 18.18.0, MariaDB 10.10, `concordconsortium/docker-solr-portal`, the CI workflow's setup steps, Chrome for Testing linked at `/usr/bin/chromium`), with the same database and app build for both runs:

| `rake ci:cucumber_search` | Result |
|---|---|
| Chrome 157.0.8103.78 | `11 scenarios (5 undefined, 6 passed)` |
| Chrome 158.0.8127.36 | `11 scenarios (6 failed, 5 undefined)`, the same six scenarios and the same progress string as CI |

Rerunning one scenario with `--format pretty --backtrace` shows the hook error:

```
invalid argument: * is not a valid URL (Selenium::WebDriver::Error::InvalidArgumentError)
  capybara-3.40.0/lib/capybara/selenium/driver_specializations/chrome_driver.rb:54:in `reset!'
  capybara-3.40.0/lib/capybara/session.rb:132:in `reset!'
  capybara-3.40.0/lib/capybara.rb:327:in `reset_sessions!'
  capybara-3.40.0/lib/capybara/cucumber.rb:11  (the After hook)
```

`Capybara::Selenium::Driver::ChromeDriver#reset!` ends with `execute_cdp('Storage.clearDataForOrigin', origin: '*', storageTypes: 'cookies,local_storage')`. Chrome 158 validates the origin and rejects `'*'`. Capybara runs `reset!` after every scenario and every system example that used the browser, so on Chrome 158 every browser test fails in teardown. Upstream this is [teamcapybara/capybara#2865](https://github.com/teamcapybara/capybara/issues/2865), with two open fix PRs (#2867, #2868). Capybara 3.40.0 (January 2024) is still the latest release, and master has the same call.

### It is not only search

On Chrome 158 locally, without a fix:

- `ci:cucumber_javascript`: 18 of 31 scenarios fail. 17 fail in the same hook. The 18th, "Anonymous users cannot create notice page", fails a real step, because the reset that should have logged the previous scenario's user out raised before clearing cookies. That is the screenshot CI's artifact held.
- `ci:spec_system_tests` (RSpec, `headless_chrome` driver): all 7 examples in `spec/system/admin_notices_spec.rb` error in teardown with the same message.

In CI those two jobs were canceled by the matrix's default fail-fast once `cucumber_search` failed, so the run never showed them failing.

### The fix, tried as throwaway code

A module prepended to `Capybara::Selenium::Driver::ChromeDriver` that replaces only the wildcard call, clearing every cookie with `Network.clearBrowserCookies` and the local storage of each http(s) origin in the tab's navigation history with `Storage.clearDataForOrigin`, gave these local results:

| Suite | Chrome 158, with the fix |
|---|---|
| `ci:cucumber_search` | 6 passed, 5 undefined (same as Chrome 157 without the fix) |
| `ci:cucumber_javascript` | 2 failed, 13 undefined, 16 passed; the 2 failures fail identically on Chrome 157 without the fix (see below) |
| `spec/system` (all) | 63 examples, 0 failures |

`ci:cucumber_search` with the fix on Chrome 157 also passes (6 passed).

The local Chrome 157 baseline for `ci:cucumber_javascript` has failures CI does not have: `admin_configures_settings.feature:31` and `:44` failed in all three runs, and `user_logs_in_using_header_login_box.feature:23` and `admin_views_districts.feature:18` in some. They are step failures (text not found, a stale element) in this local setup, independent of the Chrome version, and they pass in CI.

### Why the failures were hard to diagnose

- `ci.rake` runs cucumber with `--format progress`. Cucumber 9.2.1's progress formatter prints "F" for a failed hook but returns before recording hook results (`progress.rb`, `on_test_step_finished`: `return if test_step.hook?`), so a hook's error is never printed. `--format summary` prints only a cross. `--format pretty` prints After-hook errors unreliably: run through the rake task on Chrome 158 without a fix, it printed the error for 2 of the 6 failing scenarios, printed it for 3 undefined scenarios instead, and printed nothing for the other 4. Without `--backtrace` it also prints no frame for this error, because the default filter drops gem frames and every frame is in a gem.
- The scenario's screenshot hook (capybara-screenshot) runs before Capybara's reset hook, so a scenario that fails in the reset is not yet failed when the screenshot hook looks, and no screenshot is taken. The env.rb hook that prints browser logs has the same order and the same blind spot.
- Every test job uploads its screenshots under the same artifact name, `capybara-screenshots`. With `actions/upload-artifact@v4`, names must be unique within a run, so only one job's screenshots can be uploaded.
- With the default `fail-fast: true`, the first failing suite cancels the others, so a fault shared by several suites shows up as one.

## Requirements

### Chrome 158 reset

- R1. A browser test's session reset completes without error on Chrome 158 and later, and still on Chrome 157 and on the Alpine Chromium 119 in the development Docker image.
- R2. After a reset, no cookie from any origin remains, and local storage is empty for every http(s) origin the test's tab visited. This is what the reset cleared before Chrome 158 (cookies and local storage for all origins), except for origins the tab never navigated to, which a test cannot have written to through the app.
- R3. The workaround lives in the shared test support code, so it covers cucumber and RSpec system tests alike. It is written against Capybara 3.40.0, names the upstream issue (teamcapybara/capybara#2865), and stops the test run with a message to delete or recheck it if the bundle has any other Capybara version.
- R4. A test fails if the reset stops clearing cookies or stops clearing local storage for the app's origin.
- R5. Chrome is not pinned. The fix works on whatever Chrome CI's runner image provides.

### Result in CI

- R6. On Chrome 158, the six scenarios named in the story pass in `ci:cucumber_search`: `admin_work_with_interactives.feature:98` and `teacher_searches_groups_and_previews_instructional_materials.feature:21`, `:74`, `:84`, `:126`, `:145`.
- R7. On Chrome 158, no scenario in `ci:cucumber_javascript` and no example in `ci:spec_system_tests` fails with `* is not a valid URL`.

### Diagnosable failures

- R8. When a cucumber scenario fails in CI, in a step or in a hook, the CI log shows the error message and its full backtrace under that scenario.
- R9. Each CI test job uploads its failure screenshots as an artifact whose name includes the job's test suite, so every failing job's screenshots are uploaded and can be told apart.
- R10. When a scenario fails in a step, its screenshot (PNG and HTML) is in that job's artifact. A scenario that fails in the reset hook has no screenshot, because the screenshot hook has already run and found the scenario passing. R8's log entry is its record.
- R11. A failing test suite does not cancel the other test suites in the same CI run, so each suite's result is reported.
- R13. The CI workflow installs only the browser tooling the tests use, and its comments say which browser runs: the runner image's Chromium at `/usr/bin/chromium`, with a matching ChromeDriver. The unused Chromium install and the removal of the image's Google Chrome go.

### Constraints

- R12. The change touches only test support code and CI configuration: no application code, and no `Gemfile` or `Gemfile.lock` change. A release tagged after it merges ships the same application as before.

## Technical Notes

### Which browser CI runs

- `spec/support/capybara_initializer.rb` sets `options.binary = "/usr/bin/chromium"` in both `selenium_options` (cucumber's `:selenium` driver) and `headless_chrome_options` (the system tests' `:headless_chrome` driver).
- On GitHub's ubuntu runners `/usr/bin/chromium` is a symlink to the image's Chromium snapshot (`/usr/local/share/chromium/chrome-linux/chrome`, from `images/ubuntu/scripts/build/install-google-chrome.sh` in actions/runner-images). The image readmes list it as Chromium 157.0.8103.0 in `20261116.202` and 158.0.8127.0 in `20261122.9`.
- `.github/workflows/ci.yml` also runs `nanasess/setup-chromedriver@v2` (installs ChromeDriver matching the image's Google Chrome into `/usr/local/bin`), removes `google-chrome-stable`, and runs `browser-actions/setup-chrome@v1` with `latest`. That last step installs a Chromium snapshot (160.0.8190.0 in the failing run) under `/opt/hostedtoolcache/setup-chrome/` which nothing uses, because the driver options name `/usr/bin/chromium`. The step comments say otherwise.
- So pinning Chrome through `ci.yml` alone would pin nothing; it would also need the binary path changed in `capybara_initializer.rb`.

### Capybara's reset

- `capybara-3.40.0/lib/capybara/selenium/driver_specializations/chrome_driver.rb`: `reset!` closes extra windows, clears session and local storage through JavaScript only when the `clear_*_storage` options differ (this repo sets neither, so it skips that), navigates to `about:blank`, then makes the wildcard CDP call. `storage_types_to_clear` is `cookies,local_storage` here, because neither `clear_local_storage` nor `clear_session_storage` is set to `false`.
- `execute_cdp` is a private method of the module, and `Capybara::Selenium::Driver` extends the driver instance with the module when the browser is Chrome. A module prepended to `ChromeDriver` takes effect on that instance (verified with the throwaway fix).
- `Network.clearBrowserCookies` and `Storage.clearDataForOrigin` with a real origin work on Chrome 158, as does `Page.getNavigationHistory`. After `reset!` navigates to `about:blank`, the history still holds the app origin (the throwaway run traced `["http://127.0.0.1:<port>"]`).
- The app's own code (`app/`, `lib/`, `react-components/src`) uses neither `localStorage` nor `sessionStorage`, so cookie clearing is what scenarios depend on. Local storage is cleared to keep the reset equivalent to Capybara's.

### Hooks and order

- `features/support/env.rb` requires `cucumber/rails` (which loads Capybara's `After { Capybara.reset_sessions! }`), then `capybara-screenshot/cucumber`, then defines its own After hook (`add_browser_logs`, only when the scenario has already failed). Cucumber runs After hooks in reverse order of definition, so the browser-log and screenshot hooks run before the reset.
- `env.rb` loads `spec/spec_helper_common.rb`, which requires every file in `spec/support/**`. RSpec system tests load the same file. That makes `spec/support/` the one place a fix covers both.
- `Capybara.save_path` is `tmp/capybara` (`spec_helper_common.rb`). CI uploads `/home/runner/work/rigse/rigse/rails/tmp/capybara/**`.

### CI suites

`rails/lib/tasks/continuous_integration.rake` builds the three cucumber tasks from one `opts` string (`--profile default --tags 'not @pending' --format progress`). `config/cucumber.yml`'s default profile already passes `--format pretty` (or `CUCUMBER_FORMAT`), which the task's later `--format progress` overrides. Step counts in master's last green run: `cucumber_without_javascript` 323 steps, `cucumber_javascript` 317, `cucumber_search` 203.

## Out of Scope

- The undefined steps in the search and JavaScript features (5 and 13 undefined scenarios). They are reported as undefined, not failed, on every Chrome version.
- The local-only `cucumber_javascript` failures listed in Background.
- Browser console noise in the logs (`kit.fontawesome.com` 403, "Permissions policy violation: unload is not allowed").
- Upgrading Capybara, or pointing the Gemfile at an unreleased fork or PR branch.
- Screenshots for scenarios that fail in the reset hook (R10).

## Open Questions

### RESOLVED: Judgment call: fix the reset in the repo, or pin Chrome 157?
**Context**: The acceptance criteria allow either.
**Options considered**:
- A) Patch Capybara's Chrome reset in `spec/support`, scoped to Capybara 3.40.0.
- B) Pin Chrome 157 in CI.
- C) Point the Gemfile at one of the upstream fix PRs.

**Decision**: A. The fault is in Capybara, not Chrome, so a pin only defers it: Chrome 157 stops getting updates, every developer machine on 158 still fails, and pinning needs both `ci.yml` and `capybara_initializer.rb` changed because CI runs `/usr/bin/chromium`. C makes the test bundle depend on an unmerged branch that may be rebased or deleted. A is a few lines, verified locally on 157 and 158, and asks to be deleted or rechecked when the bundle leaves 3.40.0 (R3).

### RESOLVED: Judgment call: how cucumber should print errors in CI
**Context**: R8 needs hook errors in the log, under the scenario they belong to.
**Options considered**:
- A) Replace `--format progress` with `--format pretty --backtrace` in `ci.rake`.
- B) Keep `--format progress` and add a small cucumber plugin in `features/support/` that listens for failed test steps (steps and hooks alike) and prints the scenario's name and location, the step or hook and its location, the error class and message, and the unfiltered backtrace.
- C) Keep progress on the console and add `--format pretty --out <file>` as an artifact, or use `--format summary`.

**Decision**: B. A was the first choice and failed when run: pretty attributes After-hook errors to the wrong scenarios or drops them (Background). C puts the error where a log reader will not look (and `--out tmp/cucumber/pretty.txt` failed with `Errno::ENOENT` until the directory exists), and summary prints only a cross. B, tried as throwaway code with the rake task on Chrome 158 without a fix, reported all 11 failed reset hooks under the right scenario (the 6 failing ones and 5 undefined ones whose reset also failed), each with the hook location `capybara-3.40.0/lib/capybara/cucumber.rb:10`, the message and the full backtrace. On a step failure it reports the step and its line. The log for `cucumber_search` was 359 lines, against 879 with pretty.

### RESOLVED: Judgment call: include fail-fast in this story?
**Context**: The story's description names fail-fast as the reason every run is red; its acceptance criteria do not ask for a change.
**Options considered**:
- A) Set `fail-fast: false` on the test matrix (R11).
- B) Leave fail-fast on.

**Decision**: A, confirmed at stage 8. One line, and it is the reason this run hid two more failing suites. It costs runner minutes only on red runs.

### RESOLVED: Remove the CI browser setup steps that install a Chrome nothing uses?
**Context**: `setup-chrome@v1` installs a Chromium (160 in the failing run) that the tests never run, and the comments around the three browser steps describe a setup that is not what happens (Technical Notes). Removing them would leave CI on the runner image's Chromium and its matching ChromeDriver, which is what runs today. It is outside the story's acceptance criteria and its 1 point.
**Options considered**:
- A) Leave them; record a follow-up.
- B) Remove `setup-chrome` and the `apt-get remove` step, keep `setup-chromedriver`, and correct the comments.
- C) Remove all three and rely on the runner image's ChromeDriver.

**Decision**: B (stage 8). Recommended A to hold the story at 1 point; the cleanup was chosen instead, as R13. `setup-chromedriver` stays because it reads the image's Google Chrome version, so that Chrome must stay installed, which is why the `apt-get remove` step goes along with `setup-chrome`.

### RESOLVED: Low confidence: is local storage of origins outside the tab history worth clearing?
**Context**: R2 clears local storage only for origins in the reset tab's navigation history. Capybara closes other windows before that, so origins visited only in a closed window keep their local storage. Before Chrome 158, `'*'` cleared all of them.
**Options considered**:
- A) Accept it: the app writes no local storage, so nothing a later test reads can be left behind in another window's origin.
- B) Also collect history from every window before closing it.

**Decision**: A. Some steps read a window the app opened, through Selenium directly (`the newly opened window should have content` and `close the newly opened window` in `global_steps.rb`, the `Report page ...` steps in `report_steps.rb`, `in_newly_opened_window` in `spec/support/system_helper.rb`), so a second window does occur. But `app/`, `lib/` and `react-components/src` never touch `localStorage` or `sessionStorage`, and cookies, which the app does use, are cleared for every origin by `Network.clearBrowserCookies`. B would add code to clear storage no test writes.

## Self-Review

Roles: Senior Engineer (Capybara and Selenium), QA Engineer, DevOps Engineer (GitHub Actions), Release Manager (RIGSE-411).

### Senior Engineer

#### RESOLVED: R8 as first written could not be met with `--format pretty` alone
Run locally on Chrome 158 without a fix, `--format pretty` printed the hook's message and class but no frame, because the default backtrace filter removes gem frames and this error is raised entirely inside gems. Fixed in place: R8 asks for the full backtrace. (The formatter decision itself changed again in the implementation-assumption checks below.)

### Implementation-assumption checks

#### RESOLVED: `--format pretty --backtrace` misattributes After-hook errors
Run through `rake ci:cucumber_search` on Chrome 158 without a fix, pretty printed the reset error under 5 scenarios, only 2 of them among the 6 failing ones, and nothing under the other 4 failing ones, including the run's last scenario. A log that names the wrong scenario fails R8. Replaced with a failure-reporting plugin; see the formatter decision in Open Questions.

#### RESOLVED: The fix and its test are verified on all three browsers
A throwaway Capybara session (a Rack app that sets a cookie and a local-storage value, then `reset!` and a check page) cleared both with the fix on Alpine Chromium 119 (the dev image), Chrome 157 and Chrome 158. Without the fix, 158 raised `* is not a valid URL` and the others cleared both. With the fix's cookie clear removed, the cookie survived the reset; with its local-storage clear removed, the value survived. So R4's test can fail.

#### RESOLVED: R10 gave the wrong reason for the missing screenshot
The page is cleared by the reset, but the screenshot is missing because capybara-screenshot's After hook runs before Capybara's reset hook (reverse definition order, see Technical Notes) and sees a passing scenario. Fixed in place.

### Release Manager

#### RESOLVED: Nothing said the fix stays out of the application
RIGSE-411's production tag will be cut from master after this merges, so the release needs to know this story adds no application or dependency change. Added R12.
