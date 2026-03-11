---
name: use-case-prep
description: "Prepare a sales person for a customer conversation by looking up recommended use cases from A360, researching Snowflake product capabilities, pulling real customer stories from Raven, analyzing competitors, and generating talk tracks. Use when: preparing for customer meeting, use case prep, conversation prep, next best use case, account use case research, meeting prep for account, customer prep, prep me for a call. Triggers: use case prep, meeting prep, customer conversation, next best use case, prep me for, account prep, conversation prep."
---

# Use Case Prep

Prepare a seller for a customer conversation by combining A360 workload classification data, use case catalogs, Snowflake product knowledge, Raven customer stories, competitive intel, and tailored talk tracks.

## Prerequisites

- Connection: `sales-enablement` (role: `SALES_BASIC_RO`, warehouse: `SNOWFLAKE_INTELLIGENCE_SALES_WH`, database: `SALES`)

## Workflow

### Step 1: Account Lookup & A360 Intelligence

**Goal:** Identify the account, pull A360 workload classification, and surface whitespace opportunities.

**Actions:**

1. **Ask** the user for the account name (or partial name).

2. **Query** `SALES.RAVEN.ACCOUNT` to find the account:
   ```sql
   SELECT NAME, SALESFORCE_ACCOUNT_ID, INDUSTRY, ACCOUNT_SEGMENT_C,
          ACCOUNT_OWNER_NAME, ACCOUNT_STATUS_C,
          PREDICTED_USE_CASES_C, PREDICTED_PRODUCT_USE_CASE_C,
          USE_CASE_SPECIALIZATION_C,
          ENGAGIO_COMPETITIVE_INTENT_KEYWORDS_C, MIGRATION_COMPETENCIES_C
   FROM SALES.RAVEN.ACCOUNT
   WHERE UPPER(NAME) LIKE UPPER('%<account_name>%')
   LIMIT 10
   ```

3. If multiple matches, present them and ask the user to select one.

4. Store `SALESFORCE_ACCOUNT_ID`, `NAME`, `INDUSTRY`, and `ACCOUNT_SEGMENT_C`.

5. **Query** A360 workload classification whitespace to see what the customer is running and where opportunities exist:
   ```sql
   SELECT FUNCTIONAL_AREA, TOP_CATEGORY, SUB_CATEGORY, CREDITS_PCT, EXAMPLE_WORKLOADS
   FROM SALES.RAVEN.A360_WLC_WHITESPACE_VIEW
   WHERE SALESFORCE_ACCOUNT_ID = '<account_id>'
   ORDER BY CREDITS_PCT DESC
   ```

6. **Query** recent workload trends:
   ```sql
   SELECT WORKLOAD, SUBWORKLOAD, SUM(CREDITS) AS TOTAL_CREDITS, SUM(JOBS) AS TOTAL_JOBS
   FROM SALES.RAVEN.A360_WORKLOADS_MONTHLY_VIEW
   WHERE SALESFORCE_ACCOUNT_ID = '<account_id>'
     AND MONTH >= DATEADD('month', -3, CURRENT_DATE())
   GROUP BY WORKLOAD, SUBWORKLOAD
   ORDER BY TOTAL_CREDITS DESC
   LIMIT 15
   ```

7. **Present** the account snapshot: industry, segment, status, owner, current workloads (top areas by credit %), and whitespace opportunities.

**STOP**: Confirm the correct account and review the A360 workload data before proceeding.

### Step 2: Retrieve Use Case Details

**Goal:** Get detailed recommended use cases for this account's industry, informed by the whitespace analysis.

**Actions:**

1. **Query** the use case catalog for the account's industry:
   ```sql
   SELECT TOPIC_NAME, GENERATED_USE_CASE_NAME, GENERATED_DESCRIPTION, BUSINESS_IMPACT,
          REFERENCE_ACCOUNT_NAMES
   FROM SALES.RAVEN.USE_CASE_CATALOG_4REFERENCE
   WHERE ACCOUNT_INDUSTRY = '<industry>'
   ORDER BY TOPIC_NAME
   ```

2. **Also query** the generated use case catalog for broader coverage:
   ```sql
   SELECT TOPIC_NAME, USE_CASE_NAME, USE_CASE_DESCRIPTION, BUSINESS_IMPACT
   FROM SALES.RAVEN.USE_CASE_CATALOG_3GENERATE
   WHERE ACCOUNT_INDUSTRY = '<industry>'
   ORDER BY TOPIC_NAME
   ```

3. **Cross-reference** catalog use cases with the A360 whitespace data from Step 1. Highlight use cases that align with the customer's existing workloads (expansion opportunities) and those in whitespace areas (new opportunities).

4. **Present** the use cases grouped by topic with a recommendation flag:
   - **Expand**: customer already runs workloads in this area
   - **New opportunity**: whitespace area where the customer has no current usage

5. **Ask** the user which use case(s) they want to focus on (1-3 recommended).

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

3. **Use** the competitive signals already retrieved in Step 1 (`ENGAGIO_COMPETITIVE_INTENT_KEYWORDS_C`, `MIGRATION_COMPETENCIES_C`) to add account-specific context.

4. **Compile** competitor summary: which competitors appear most, in what contexts, and key differentiators.

### Step 4: Research Snowflake Product Capabilities

**Goal:** Get technical product details relevant to the use case.

**Actions:**

1. Based on the selected use case topic, description, and A360 workload data, identify the core Snowflake products/features involved (e.g., Cortex AI, Dynamic Tables, Snowpipe Streaming, Data Sharing, Iceberg, Snowpark).

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
- Account name, industry, segment, status, owner
- Current workload profile from A360 (top areas by credit %)
- Contract health signals (if available)

#### 2. Workload Intelligence & Whitespace
- What the customer is running today (from A360 WLC)
- Whitespace opportunities (areas with no current usage)
- Recent workload trends (growing vs declining areas)

#### 3. Recommended Use Case Focus
- Use case name and description
- Business impact and industry outcomes
- Whether this is an expansion or new opportunity for this account
- Why this matters for THIS customer specifically

#### 4. Snowflake Solution Overview
- Key Snowflake products/features that enable this use case
- Technical capabilities in business-friendly terms
- Architecture highlights (1-2 sentences)

#### 5. Customer Proof Points
- Similar customer stories (anonymized where appropriate)
- Pain points addressed and metrics achieved
- How Snowflake solved it (PROBLEM -> SOLUTION -> RESULT pattern)

#### 6. Competitive Landscape
- Known competitors in this account or similar deals
- Key differentiators vs each competitor
- Where Snowflake wins and potential objections

#### 7. Talk Track & Discovery Questions
Generate 5-7 tailored discovery questions such as:
- Questions that uncover the customer's current pain related to this use case
- Questions that leverage A360 workload data (e.g., "We see you're investing heavily in X — how is that going?")
- Questions that reveal decision criteria and timeline
- Questions that position Snowflake's strengths vs competitors
- A 30-second elevator pitch for the use case

Also generate a brief objection-handling guide for the top 2-3 likely objections based on competitor data.

**Present** the complete brief to the user.

**STOP**: Ask if user wants to refine any section or explore additional use cases.

## Stopping Points

- After Step 1: Account confirmed, A360 workload data reviewed
- After Step 2: Use case(s) selected
- After Step 5: Brief delivered, optional refinement

## Output

A comprehensive conversation prep brief with A360 workload intelligence, whitespace analysis, use case details, technical capabilities, customer proof points, competitive positioning, and tailored talk tracks.

## Troubleshooting

**Account not found:**
- Try partial name or alternate spellings
- Query: `SELECT NAME FROM SALES.RAVEN.ACCOUNT WHERE UPPER(NAME) LIKE '%<partial>%' LIMIT 20`

**No A360 workload data:**
- The account may not have active Snowflake usage yet (prospect vs customer)
- Skip whitespace analysis and rely on industry-level use case catalog instead

**No use case catalog entries for industry:**
- Fall back to broader search across all industries with keyword matching
- Use `USE_CASE_QUALITY_STORIES` as primary source instead

**No competitor data:**
- Check `USE_CASE_STORIES_PSEUDO` table: `COMPETITORS_C`, `MEDDPICC_COMPETITORS` columns
- Note this gap in the brief and suggest the seller gather competitive intel during discovery

## Notes

- All queries use connection `sales-enablement` with role `SALES_BASIC_RO`
- Data is read-only; no modifications to underlying tables
- Use case catalog covers 10 industries and 53 topic areas
- Quality stories include MEDDPICC-aligned fields (pain, metrics, decision criteria, champions, competitors)
- A360 WLC data shows actual customer workloads and whitespace opportunities
- This role is available to all AEs and SEs with SALES_BASIC_RO (5,800+ users)
