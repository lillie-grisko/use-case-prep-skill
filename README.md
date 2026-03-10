# Use Case Prep — Cortex Code Skill

A Cortex Code skill that helps sellers prepare for customer conversations by combining account data, use case catalogs, customer stories, competitive intel, and Snowflake documentation into a ready-to-use conversation brief.

## Install

```bash
git clone https://github.com/lillie-grisko/use-case-prep-skill.git
bash use-case-prep-skill/setup-use-case-prep.sh
```

Or download just the setup script and run:

```bash
bash setup-use-case-prep.sh
```

The script will:

1. Install the skill to `~/.snowflake/cortex/skills/use-case-prep/SKILL.md`
2. Add the `sales-enablement` connection to your `~/.snowflake/connections.toml` (or skip if it exists)
3. Remind you to set your `user` and verify you have `SALES_ENABLEMENT_RO_RL` granted

## Post-Install

1. Open `~/.snowflake/connections.toml` and add your Snowflake username to the `[sales-enablement]` section:
   ```toml
   user = "YOUR_USERNAME"
   ```
2. Verify you have the `SALES_ENABLEMENT_RO_RL` role. If unsure, ask your manager or run in Snowflake:
   ```sql
   SHOW GRANTS TO USER YOUR_USERNAME;
   ```

## Usage

Open Cortex Code and type:

> prep me for a call with Acme Corp

The skill will walk you through a 5-step workflow:

1. **Account Lookup** — pull recommended use cases from A360
2. **Use Case Details** — fetch technical details from the use case catalog
3. **Customer Stories & Competitor Intel** — find real customer wins and competitive positioning
4. **Snowflake Docs Research** — research product capabilities from Snowflake documentation
5. **Conversation Prep Brief** — generate a structured brief with talk tracks
