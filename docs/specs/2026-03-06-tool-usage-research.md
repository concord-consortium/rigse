# Tool Usage Research

**Date:** 2026-03-06
**Status:** Pending
**Related:** `2026-03-06-oauth2-launch-parameter-research.md`, `../portal-authentication-unification-design.md` Section 9 Next Steps, Step 3

---

## Purpose

Research questions about Tool model usage that need to be answered before implementing OAuth2 launch support on the Tool model.

---

## 1. LARA Tool Activity Usage

Before removing the LARA launch path in `offerings_controller.rb` (lines 52-71), we need to confirm that no ExternalActivities in production still use a Tool with `source_type: 'LARA'`. The `lara2.rake` migration task was designed to migrate LARA activities to Activity Player, but we need to verify it was run on production and that no LARA-tool activities remain in active use.

### Query 1a: Count ExternalActivities with the LARA tool

This checks whether any ExternalActivities still reference the LARA tool, and how many are assigned to classes.

```bash
docker compose exec app bundle exec rails runner "
  lara_tool = Tool.find_by(source_type: 'LARA')
  if lara_tool
    count = ExternalActivity.where(tool_id: lara_tool.id).count
    assigned = ExternalActivity.where(tool_id: lara_tool.id).where('offerings_count > 0').count
    puts \"LARA tool id: #{lara_tool.id}\"
    puts \"ExternalActivities with LARA tool: #{count}\"
    puts \"  ...with offerings (assigned): #{assigned}\"
  else
    puts 'No LARA tool found'
  end
"
```

### Query 1b: Check for recent launches of LARA-tool activities

This checks whether any learner has launched a LARA-tool activity in the last year by looking at `last_run` timestamps on learner records for offerings whose runnable is a LARA-tool ExternalActivity.

```bash
docker compose exec app bundle exec rails runner "
  lara_tool = Tool.find_by(source_type: 'LARA')
  if lara_tool
    lara_ea_ids = ExternalActivity.where(tool_id: lara_tool.id).pluck(:id)
    offering_ids = Portal::Offering.where(runnable_type: 'ExternalActivity', runnable_id: lara_ea_ids).pluck(:id)
    recent = Portal::Learner.where(offering_id: offering_ids).where('last_run > ?', 1.year.ago)
    puts \"Offerings for LARA-tool activities: #{offering_ids.count}\"
    puts \"Learners who launched in the last year: #{recent.count}\"
    if recent.count > 0
      most_recent = recent.order(last_run: :desc).first
      puts \"Most recent launch: #{most_recent.last_run}\"
      puts \"  Offering ID: #{most_recent.offering_id}\"
      ea = Portal::Offering.find(most_recent.offering_id).runnable
      puts \"  ExternalActivity: #{ea.name} (id: #{ea.id})\"
    end
  else
    puts 'No LARA tool found'
  end
"
```

---

## 2. Logging Parameter in Non-LARA Launches

Investigation found that the `logging` parameter is passed in the LARA launch path (`offerings_controller.rb:57`) and the collaboration launch path (`create_collaboration.rb:77`), but **not** in the standard non-LARA assignment launch path (`external_activity.rb#url`). This means Activity Player activities launched via the non-LARA path do not receive a `logging` parameter.

Either Activity Player derives `logging` from the offerings API after launch, or this has been missing. This needs to be confirmed.

### Query 2: Check how Activity Player handles logging

Search the Activity Player client codebase (`concord-consortium/activity-player`) for how it determines whether logging is enabled. Look for:
- References to a `logging` URL parameter
- Fetching logging state from the offerings API response
- Any Firestore/Firebase logging configuration

---

## Results

_Run the queries above on production and record the results here._
