#!/bin/bash
# Setup script for the use-case-prep Cortex Code skill
# Usage: bash setup-use-case-prep.sh

set -e

SKILL_DIR="$HOME/.snowflake/cortex/skills/use-case-prep"
CONNECTIONS_FILE="$HOME/.snowflake/connections.toml"

echo "=== Use Case Prep Skill Setup ==="
echo ""

# Step 1: Create skill directory and copy SKILL.md
echo "[1/3] Installing skill..."
mkdir -p "$SKILL_DIR"

cat > "$SKILL_DIR/SKILL.md" << 'SKILL_EOF'
---
name: use-case-prep
description: "Prepare a sales person for a customer conversation by looking up recommended use cases from A360, researching Snowflake product capabilities, pulling real customer stories from Raven, analyzing competitors, and generating talk tracks. Use when: preparing for customer meeting, use case prep, conversation prep, next best use case, account use case research, meeting prep for account, customer prep, prep me for a call. Triggers: use case prep, meeting prep, customer conversation, next best use case, prep me for, account prep, conversation prep."
---

# Use Case Prep

Prepare a seller for a customer conversation by combining A360 predicted use cases, Snowflake product knowledge, Raven customer stories, competitive intel, and tailored talk tracks.

## Prerequisites

- Connection: `sales-enablement` (role: `SALES_ENABLEMENT_RO_RL`, warehouse: `ENABLEMENT_WH`, database: `SALES`)

## Workflow

### Step 1: Account Lookup

**Goal:** Identify the customer account and its predicted/recommended use cases.

**Actions:**

1. **Ask** the user for the account name (or partial name).

2. **Query** `SALES.RAVEN.ACCOUNT` to find the account:
   ```sql
   SELECT NAME, SALESFORCE_ACCOUNT_ID, INDUSTRY, ACCOUNT_OWNER_NAME, ACCOUNT_STATUS_C,
          PREDICTED_USE_CASES_C, PREDICTED_PRODUCT_USE_CASE_C, USE_CASE_SPECIALIZATION_C
   FROM SALES.RAVEN.ACCOUNT
   WHERE UPPER(NAME) LIKE UPPER('%<account_name>%')
   LIMIT 10
   ```

3. If multiple matches, present them and ask the user to select one.

4. Store the `SALESFORCE_ACCOUNT_ID`, `NAME`, and `INDUSTRY` for subsequent queries.

**STOP**: Confirm the correct account before proceeding.

### Step 2: Retrieve Use Case Details

**Goal:** Get detailed recommended use cases for this account's industry.

**Actions:**

1. **Query** the use case catalog for the account's industry:
   ```sql
   SELECT TOPIC_NAME, GENERATED_USE_CASE_NAME, GENERATED_DESCRIPTION, BUSINESS_IMPACT,
          REFERENCE_ACCOUNT_NAMES
   FROM SALES.RAVEN.USE_CASE_CATALOG_4REFERENCE
   WHERE ACCOUNT_INDUSTRY = '<industry>'
   ORDER BY TOPIC_NAME
   ```

2. **Also query** use case catalog generate for broader coverage:
   ```sql
   SELECT TOPIC_NAME, USE_CASE_NAME, USE_CASE_DESCRIPTION, BUSINESS_IMPACT
   FROM SALES.RAVEN.USE_CASE_CATALOG_3GENERATE
   WHERE ACCOUNT_INDUSTRY = '<industry>'
   ORDER BY TOPIC_NAME
   ```

3. **Present** the use cases grouped by topic, showing name, description, and business impact.

4. **Ask** the user which use case(s) they want to focus on for the conversation (1-3 recommended).

**STOP**: User selects focus use case(s).

### Step 3: Gather Real Customer Stories & Competitive Intel

**Goal:** Pull proof points from similar deployments and identify competitor landscape.

**Actions:**

1. **Query** high-quality use case stories matching the selected topic/industry:
   ```sql
   SELECT USE_CASE_NAME, USE_CASE_DESCRIPTION, USE_CASE_STAGE, INDUSTRY, SUB_INDUSTRY,
          IDENTIFY_PAIN_ADJ, METRICS_ADJ, COMPETITORS_ADJ,
          PROBLEM_CHALLENGE, SNOWFLAKE_SOLUTION, RESULT_OF_IMPACT
   FROM SALES.RAVEN.USE_CASE_QUALITY_STORIES
   WHERE INDUSTRY = '<industry>'
     AND (LOWER(USE_CASE_NAME) LIKE '%<keyword>%' OR LOWER(USE_CASE_DESCRIPTION) LIKE '%<keyword>%')
   LIMIT 5
   ```

2. **Query** competitor data from use case deliverables:
   ```sql
   SELECT NAME, USE_CASE_STAGE, COMPETITORS_C, MEDDPICC_COMPETITORS, INDUSTRY_SOLUTION_C
   FROM SALES.RAVEN.USE_CASE_EXPLORER_VH_DELIVERABLE_C
   WHERE (LOWER(NAME) LIKE '%<keyword>%' OR LOWER(VH_DESCRIPTION_C) LIKE '%<keyword>%')
     AND COMPETITORS_C IS NOT NULL
   LIMIT 10
   ```

3. **Query** account-level competitive signals:
   ```sql
   SELECT NAME, ENGAGIO_COMPETITIVE_INTENT_KEYWORDS_C, MIGRATION_COMPETENCIES_C
   FROM SALES.RAVEN.ACCOUNT
   WHERE SALESFORCE_ACCOUNT_ID = '<account_id>'
   ```

4. **Compile** competitor summary: which competitors appear most, in what contexts, and key differentiators.

### Step 4: Research Snowflake Product Capabilities

**Goal:** Get technical product details relevant to the use case.

**Actions:**

1. Based on the selected use case topic and description, identify the core Snowflake products/features involved (e.g., Cortex AI, Dynamic Tables, Snowpipe Streaming, Data Sharing, Iceberg, Snowpark).

2. **Use** `web_search` to find relevant docs from docs.snowflake.com:
   ```
   web_search: "<snowflake_feature> site:docs.snowflake.com"
   ```

3. **Use** `web_fetch` to pull key capability summaries from the top results.

4. **Summarize** the technical capabilities in business-friendly language: what it does, why it matters, how it solves the customer's problem.

### Step 5: Generate Conversation Prep Brief

**Goal:** Synthesize everything into an actionable conversation prep document.

**Actions:**

Produce a structured brief with these sections:

#### 1. Account Snapshot
- Account name, industry, status, owner
- Predicted use cases from A360

#### 2. Recommended Use Case Focus
- Use case name and description
- Business impact and industry outcomes
- Why this matters for THIS customer specifically

#### 3. Snowflake Solution Overview
- Key Snowflake products/features that enable this use case
- Technical capabilities in business-friendly terms
- Architecture highlights (1-2 sentences)

#### 4. Customer Proof Points
- Similar customer stories (anonymized where appropriate)
- Pain points addressed and metrics achieved
- How Snowflake solved it (PROBLEM -> SOLUTION -> RESULT pattern)

#### 5. Competitive Landscape
- Known competitors in this account or similar deals
- Key differentiators vs each competitor
- Where Snowflake wins and potential objections

#### 6. Talk Track & Discovery Questions
Generate 5-7 tailored discovery questions such as:
- Questions that uncover the customer's current pain related to this use case
- Questions that reveal decision criteria and timeline
- Questions that position Snowflake's strengths vs competitors
- A 30-second elevator pitch for the use case

Also generate a brief objection-handling guide for the top 2-3 likely objections based on competitor data.

**Present** the complete brief to the user.

**STOP**: Ask if user wants to refine any section or explore additional use cases.

## Stopping Points

- After Step 1: Account confirmed
- After Step 2: Use case(s) selected
- After Step 5: Brief delivered, optional refinement

## Output

A comprehensive conversation prep brief with account context, use case details, technical capabilities, customer proof points, competitive positioning, and tailored talk tracks.

## Troubleshooting

**Account not found:**
- Try partial name or alternate spellings
- Query: `SELECT NAME FROM SALES.RAVEN.ACCOUNT WHERE UPPER(NAME) LIKE '%<partial>%' LIMIT 20`

**No use case catalog entries for industry:**
- Fall back to broader search across all industries with keyword matching
- Use `USE_CASE_QUALITY_STORIES` as primary source instead

**No competitor data:**
- Check `USE_CASE_STORIES_PSEUDO` table: `COMPETITORS_C`, `MEDDPICC_COMPETITORS` columns
- Note this gap in the brief and suggest the seller gather competitive intel during discovery

## Notes

- All queries use connection `sales-enablement` with role `SALES_ENABLEMENT_RO_RL`
- Data is read-only; no modifications to underlying tables
- Use case catalog covers 10 industries and 53 topic areas
- Quality stories include MEDDPICC-aligned fields (pain, metrics, decision criteria, champions, competitors)
SKILL_EOF

echo "  Installed to: $SKILL_DIR/SKILL.md"

# Step 2: Add sales-enablement connection if not already present
echo "[2/3] Configuring Snowflake connection..."

if [ ! -f "$CONNECTIONS_FILE" ]; then
    echo "  Creating $CONNECTIONS_FILE..."
    mkdir -p "$(dirname "$CONNECTIONS_FILE")"
    cat > "$CONNECTIONS_FILE" << 'CONN_EOF'
[sales-enablement]
account = "SFCOGSOPS-SNOWHOUSE_AWS_US_WEST_2"
authenticator = "externalbrowser"
role = "SALES_ENABLEMENT_RO_RL"
warehouse = "ENABLEMENT_WH"
database = "SALES"
CONN_EOF
    echo "  Created with sales-enablement connection."
    echo "  NOTE: Edit $CONNECTIONS_FILE and add your 'user = \"YOUR_USERNAME\"' to the [sales-enablement] section."
elif grep -q '\[sales-enablement\]' "$CONNECTIONS_FILE"; then
    echo "  Connection [sales-enablement] already exists. Skipping."
else
    cat >> "$CONNECTIONS_FILE" << 'CONN_EOF'

[sales-enablement]
account = "SFCOGSOPS-SNOWHOUSE_AWS_US_WEST_2"
authenticator = "externalbrowser"
role = "SALES_ENABLEMENT_RO_RL"
warehouse = "ENABLEMENT_WH"
database = "SALES"
CONN_EOF
    echo "  Appended [sales-enablement] connection."
    echo "  NOTE: Edit $CONNECTIONS_FILE and add your 'user = \"YOUR_USERNAME\"' to the [sales-enablement] section."
fi

# Step 3: Verify
echo "[3/3] Verifying installation..."

if [ -f "$SKILL_DIR/SKILL.md" ]; then
    echo "  Skill file: OK"
else
    echo "  ERROR: Skill file not found!"
    exit 1
fi

if grep -q '\[sales-enablement\]' "$CONNECTIONS_FILE"; then
    echo "  Connection config: OK"
else
    echo "  WARNING: sales-enablement connection not found in $CONNECTIONS_FILE"
fi

echo ""
echo "=== Setup Complete ==="
echo ""
echo "NEXT STEPS:"
echo "  1. Ensure 'user = \"YOUR_USERNAME\"' is set in the [sales-enablement] section of:"
echo "     $CONNECTIONS_FILE"
echo ""
echo "  2. Verify you have the SALES_ENABLEMENT_RO_RL role granted to your user."
echo "     Run in Snowflake: SHOW GRANTS TO USER <YOUR_USERNAME>;"
echo ""
echo "  3. Open Cortex Code and try: 'prep me for a call with [account name]'"
echo ""
