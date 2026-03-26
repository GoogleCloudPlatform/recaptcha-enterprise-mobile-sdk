---
name: integrating-recaptcha-transaction-defense
description: Integrates reCAPTCHA Enterprise Transaction Defense and automates ground truth via PSP chargeback webhooks (Stripe, Adyen). Use when a user wants to protect transactions from fraud and close the feedback loop with automated annotations. Don't use for generic reCAPTCHA v2 checkbox integrations or non-transactional bot protection.
---

# reCAPTCHA Transaction Defense Integrator

This skill helps you integrate reCAPTCHA Transaction Defense into your Node.js
application and automate the "ground truth" feedback loop by listening to
chargeback notifications from Payment Service Providers (PSPs) like Stripe and
Adyen.

## Prerequisites

1.  **Google Cloud Project**: reCAPTCHA Enterprise must be enabled. The Fraud
    Prevention feature must also be enabled in the reCAPTCHA settings for the
    project.
2.  **Authentication**: Your server must be authenticated to Google Cloud. The
    easiest way is to set the `GOOGLE_APPLICATION_CREDENTIALS` environment
    variable pointing to a downloaded Service Account JSON key.
3.  **IAM Roles**: The authenticated Service Account requires the **`reCAPTCHA
    Enterprise Agent`** (`roles/recaptchaenterprise.agent`) role to create and
    annotate assessments. During the execution of this agent skill,
    **`roles/logging.viewer`** is required so that the skill can automatically
    validate the success of implementation.
4.  **Environment Separation**: Create **two** reCAPTCHA keys: one for **Test**
    (allowed domains: `localhost`, `127.0.0.1`) and one for **Prod** (your real
    domain). Map these to environment variables (e.g., `RECAPTCHA_SITE_KEY_TEST`
    and `RECAPTCHA_SITE_KEY_PROD`) to avoid "Invalid Domain" errors during
    development.
5.  **Node.js Dependencies**: Run `npm install
    @google-cloud/recaptcha-enterprise` to install the required client library.

## Workflows

### 1. Integrate reCAPTCHA

First check if the user is using a V3 key. This skill so far only supports the
V3 integration.

**Codebase Survey**: Passively inspect the user's codebase and dependencies
(`package.json`, environment files, structure) to understand: 1. **Frontend
Framework**: React, Vue, Angular, or Vanilla JS? 2. **State Management**: How is
form state handled? 3. **Entry Point**: Where is the best place to inject the
`<script>` tag? 4. **Secrets Management**: Determine how the backend application
manages secrets (e.g., `.env`, Secret Manager). Adapt the secret loading when
injecting the integration logic to match this pattern.

Then use [v3.md](references/v3.md) to understand common integration gotchas.

**Action**: Read the text in `assets/frontend-snippets.html` and
`assets/frontend-snippets.js`. **Instruction**: Inject those snippets directly
into the user's *existing* frontend code, adapting them on the fly to match the
discovered Framework and State Management patterns.

### 2. Integrate Transaction Protection (Best Practice: Multi-Stage)

Protecting a transaction is most effective when done in two stages:

1.  **Stage 1: Initial Frontend Assessment**: Collect the reCAPTCHA token on the
    frontend (using `enterprise.js`) and send it to your backend. Perform a
    `createAssessment` with the token and user identifiers (email). Block bots
    and high-risk requests immediately.
2.  **Stage 2: Post-Authorization Enriched Assessment**: Use a Payment Service
    Provider (PSP) like Stripe with **manual capture**. After the user
    authorizes the payment, use the webhook to retrieve real card data (last 4
    digits, billing zip). Perform a **second** `createAssessment` with this
    enriched data to catch "stolen instrument" fraud before capturing funds.

**Codebase Survey (Database & Architecture)**: You must store the
`assessmentName` or reCAPTCHA token to close the loop later. 1. **Architecture
Check**: Is the payment processing in the same service as the frontend serving?
If separated (Microservices), ensure you identify how to pass the
`transactionId` across the boundary. 2. **Schema Check**: Identify the
**Database Schema** and **ORM** (e.g., Prisma, Sequoia, TypeORM). *
**CRITICAL**: `assessmentName` can be long. Use `VARCHAR(255)` or `TEXT`.
Converting it to a standard UUID column (36 chars) will cause truncation and
failures. 3. **Mapping Strategy**: Determine where to store the `transactionId`
<-> `assessmentName` mapping.

> **CRITICAL WARNING: Token Storage** Do **NOT** store the reCAPTCHA token in
> Stripe's `metadata` field. The token is often larger than 2000 characters,
> which exceeds Stripe's 500-character limit for metadata values, causing the
> request to fail.
>
> **Solution**: 1. Generate a unique `transactionId` on your server. 2. Store
> the token in a server-side store (e.g., Redis, Database, or in-memory map)
> using the `transactionId` as the key. 3. Pass only the `transactionId` in the
> Stripe metadata. 4. In your webhook, retrieve the token using the
> `transactionId` from the metadata.

**Reference**: See [recaptcha-api.md](references/recaptcha-api.md) for
request/response schemas and the `expectedAction` requirement.

**Action**: Read `assets/recaptcha-integration.js` and generate an equivalent
Node.js integration within the user's backend codebase.

> **Note**: The template uses placeholders (e.g., `'YOUR_PROJECT_ID'`). You must
> manually wire these to the user's environment variables (e.g.,
> `process.env.CLOUD_PROJECT_ID`).

**Wiring**: 1. Import the generated `recaptcha-integration.js` in your payment
processing route. 2. Call `createAssessment` **before** authorizing the charge
with your PSP.

**Best Practice**: Adopt a **Fail Open** strategy. If the reCAPTCHA API fails or
returns an error (other than a fraudulent verdict), allow the transaction to
proceed to avoid blocking legitimate users during outages. (The generated code
includes a try/catch block for this purpose).

### 3. Automate Ground Truth & Feedback Loop

The reCAPTCHA model improves when you provide feedback:

1.  **Annotate**: When a transaction is confirmed as legitimate or fraudulent
    (e.g., via a chargeback), call `annotateAssessment`.
2.  **Webhooks**: Map PSP events (like Stripe's `charge.dispute.created`) to the
    original reCAPTCHA assessment name.

**Reference**: See [psp-webhooks.md](references/psp-webhooks.md) for
PSP-specific webhook handling.

**Action**: Determine if the user is using `stripe` or `adyen` by reading
`package.json`. Read the corresponding template (`assets/webhook-stripe.js` or
`assets/webhook-adyen.js`) and inject the endpoint into their backend.

> **Note**: If neither are detected directly in `package.json` (e.g., wrapped
> via another library), look for imports or environment variables containing
> "Stripe", "Adyen", or "Payment" to identify the integration point manually
> before proceeding.

### 4. Verify Integration Health & End-to-End Test

**Step 1: Metric Check** To confirm that your keys are active and receiving
traffic, query the reCAPTCHA Enterprise API for metrics. **Action**: Read
`assets/check-status.js`. Create this script temporarily in their workspace and
execute it via `node` (ensuring environment variables are populated). Review the
outputs and delete the script.

**Step 2: Logic Verification (Unit Test)** Verify your integration logic handles
good, bad, and invalid tokens correctly without needing real traffic.
**Action**: Read `assets/verify-logic.js`. Create a temporary verification
script with the contents in the user's workspace, modifying the
`require('./recaptcha-integration')` line to match wherever you injected the
integration module in the previous step. Execute it via `node`, then delete it.
This checks the `createAssessment` function against various scenarios (high
score, low score, wrong action).

**Step 3: End-to-End Transaction Test (Mandatory)** Do not consider the task
complete until you have verified the full flow: 1. **Frontend**: Load the page,
check browser console for reCAPTCHA token generation. 2. **Backend**: Process a
test transaction (e.g., using Stripe Test Mode card numbers). 3. **Logs**: Check
server logs to confirm `createAssessment` was called and returned a verdict. 4.
**Webhook (Optional)**: Trigger a test dispute in the PSP dashboard and verify
your webhook receives it.

## Resources

-   **API Documentation**: [recaptcha-api.md](references/recaptcha-api.md)
-   **PSP Webhooks Guide**: [psp-webhooks.md](references/psp-webhooks.md)
-   **Integration Asset**: `assets/recaptcha-integration.js`
-   **Frontend Assets**: `assets/frontend-snippets.html`,
    `assets/frontend-snippets.js`
-   **Verification Asset**: `assets/verify-logic.js`
-   **Webhook Assets**: `assets/webhook-stripe.js`, `assets/webhook-adyen.js`
-   **Status Check Asset**: `assets/check-status.js`
