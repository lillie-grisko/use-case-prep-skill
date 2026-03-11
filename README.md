# Use Case Prep — Cortex Code Skill

A Cortex Code skill that helps sellers prepare for customer conversations by combining A360 workload intelligence, use case catalogs, customer stories, competitive intel, and Snowflake documentation into a ready-to-use conversation brief.

## Quick Install

Paste this into Cortex Code Desktop chat:

> Run this command: `curl -sL https://raw.githubusercontent.com/lillie-grisko/use-case-prep-skill/main/setup-use-case-prep.sh | bash`

It will ask for your Snowflake username, install the skill, and configure the connection automatically. No other steps required.

## What It Does

Uses the `SALES_BASIC_RO` role (available to all AEs and SEs) to access:

- **A360 Workload Classification** — what customers are running and where whitespace exists
- **Use Case Catalogs** — 53 topics across 10 industries with business impact descriptions
- **Customer Stories** — MEDDPICC-aligned proof points (pain, metrics, competitors, solution, results)
- **Competitive Intel** — account-level and deal-level competitor signals
- **Snowflake Docs** — live product capability research from docs.snowflake.com

## Usage

Open Cortex Code and type:

> prep me for a call with Acme Corp

The skill walks you through 5 steps:

1. **Account Lookup & A360 Intelligence** — find the account, pull workload classification and whitespace data
2. **Use Case Details** — fetch recommended use cases cross-referenced with actual workload data
3. **Customer Stories & Competitor Intel** — find real customer wins and competitive positioning
4. **Snowflake Docs Research** — research product capabilities from Snowflake documentation
5. **Conversation Prep Brief** — generate a 7-section brief with talk tracks and discovery questions

## Your Brief Includes

- Account snapshot with A360 workload profile
- Workload intelligence and whitespace opportunities
- Recommended use case focus (expansion vs new opportunity)
- Snowflake solution overview in business-friendly language
- Customer proof points (Problem → Solution → Result)
- Competitive landscape and differentiators
- Tailored talk track, discovery questions, and objection handling

## Need Help?

Contact Lillie Grisko for access issues or skill feedback.
