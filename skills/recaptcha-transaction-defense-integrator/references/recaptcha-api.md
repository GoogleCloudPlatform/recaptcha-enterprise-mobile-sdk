# reCAPTCHA Enterprise Transaction Defense API

Transaction Defense helps detect fraudulent transactions like account takeover,
credit card testing, and fraudulent purchases.

## Best Practice: Multi-Stage Assessment

The most secure integration uses a two-stage pattern:

1.  **Front-Office Assessment**: Done at checkout button click. Uses a frontend
    `token`. Validates bot risk and initial fraud indicators.
2.  **Back-Office Assessment**: Done after payment authorization (via webhook).
    Does **not** require a new token. Uses real card details (last 4, billing
    zip) to get a final fraud verdict before capturing funds.

## Assessment Creation

To protect a transaction, create an assessment with a `transactionData` object.

### Key Fields

- `token`: Required for front-office assessments.
- `siteKey`: Your Enterprise Site Key.
- `expectedAction`: **Best Practice**. Set this on the frontend (e.g., `checkout`) and verify it on the backend.
- `transactionData`: Object containing `transactionId`, `value`, `currencyCode`, and `user.email`.

### Request Body Example (Back-Office / Enriched)

```json
{
  "event": {
    "siteKey": "YOUR_SITE_KEY",
    "expectedAction": "checkout",
    "transactionData": {
      "transactionId": "TRANSACTION_ID",
      "paymentMethod": "credit_card",
      "currencyCode": "USD",
      "value": 5.00,
      "cardLastFour": "4242",
      "billingAddress": {
        "postalCode": "94043",
        "regionCode": "US"
      },
      "user": {
        "email": "user@example.com"
      }
    }
  }
}
```

### Assessment Response

- `riskAnalysis.score`: Bot score (0.0 to 1.0).
- `fraudPreventionAssessment.transactionVerdict`: `LEGITIMATE`, `FRAUDULENT`, `SUSPICIOUS`.

## Ground Truth (Annotate Assessment)

Providing ground truth (e.g., chargebacks) helps improve the model.

### Request

`POST https://recaptchaenterprise.googleapis.com/v1/projects/PROJECT_ID/assessments/ASSESSMENT_ID:annotate`

```json
{
  "annotation": "FRAUDULENT",
  "reasons": ["CHARGEBACK_FRAUD"]
}
```

## Resilience & Error Handling

In production, decide on a "Fail Open" or "Fail Closed" strategy:

*   **Fail Closed**: If the API fails, the transaction is blocked. High security, but risk of lost revenue.
*   **Fail Open (Recommended)**: If the `createAssessment` call throws an error, allow the transaction to proceed to the payment gateway but flag it for "Manual Review" in your internal dashboard.

## Advanced transactionData Fields

To maximize detection accuracy, provide as many identifiers as possible:

*   **`user.email`**: Primary identifier.
*   **`user.hashedAccountId`**: A stable, hashed ID for the user (e.g., `sha256(userId)`). This helps detect account takeovers and multi-accounting.
*   **`billingAddress.postalCode`**: Critical for cross-referencing with card issuer data.
*   **`cardLastFour`**: Necessary for linking assessments to specific payment instruments.
