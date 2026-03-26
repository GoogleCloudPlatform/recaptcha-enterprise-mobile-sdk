# PSP Chargeback & Authorization Webhooks

## Best Practice: Manual Capture Workflow

To maximize fraud protection, use the **Manual Capture** pattern. This allows
you to authorize the payment, retrieve card details, and perform a final
reCAPTCHA assessment before actually taking the funds.

### Stripe Manual Capture Example

1.  **Authorize**: Create a Checkout Session with `payment_intent_data: { capture_method: 'manual' }`.
2.  **Webhook**: Listen for `checkout.session.completed`.
3.  **Enrich & Capture**:

```javascript
// Stripe requires the raw body to construct the event and verify the signature
app.post('/webhooks/stripe', express.raw({type: 'application/json'}), async (req, res) => {
  const sig = req.headers['stripe-signature'];
  let event;

  try {
    event = stripe.webhooks.constructEvent(req.body, sig, endpointSecret);
  } catch (err) {
    return res.status(400).send(`Webhook Error: ${err.message}`);
  }
  
  if (event.type === 'checkout.session.completed') {
    const session = event.data.object;
    const piId = session.payment_intent;
    
    // 1. Retrieve PI with expanded payment_method to get Card Last 4 and Zip
    const pi = await stripe.paymentIntents.retrieve(piId, { expand: ['payment_method'] });
    const card = pi.payment_method.card;
    const billing = pi.payment_method.billing_details;
    
    // 2. Perform SECOND reCAPTCHA Assessment with card data
    const assessment = await recaptcha.createAssessment({
      transactionData: {
        cardLastFour: card.last4,
        billingAddress: { postalCode: billing.address.postal_code }
        // ... other fields
      }
    });
    
    // 3. Capture only if not FRAUDULENT
    if (assessment.fraudPreventionAssessment.transactionVerdict !== 'FRAUDULENT') {
      await stripe.paymentIntents.capture(piId);
    } else {
      // Handle fraud (e.g., cancel/refund)
    }
  }
  res.json({received: true});
});
```

## Chargeback Ground Truth (Annotate Assessment)

Providing ground truth (e.g., chargebacks) helps improve the model.

### Stripe Webhook Event: `charge.dispute.created`

When a dispute is created, you need to find the original `assessmentName`
stored in the metadata.

```javascript
// Express example
app.post('/webhooks/stripe', express.raw({type: 'application/json'}), async (req, res) => {
  const sig = req.headers['stripe-signature'];
  let event;

  try {
    event = stripe.webhooks.constructEvent(req.body, sig, endpointSecret);
  } catch (err) {
    return res.status(400).send(`Webhook Error: ${err.message}`);
  }
  
  if (event.type === 'charge.dispute.created') {
    const dispute = event.data.object;
    
    try {
      // 1. Get the PaymentIntent (where we stored metadata during checkout)
      // Note: The Stripe Dispute object contains the payment_intent natively.
      const paymentIntent = await stripe.paymentIntents.retrieve(dispute.payment_intent);
      
      const assessmentName = paymentIntent.metadata.assessmentName;
      
      if (assessmentName) {
        console.log(`Annotating assessment ${assessmentName} as FRAUDULENT...`);
        await recaptchaClient.annotateAssessment({
          assessmentName: assessmentName,
          annotation: 'FRAUDULENT',
          reasons: ['CHARGEBACK_FRAUD']
        });
      }
    } catch (err) {
      console.error('Error handling dispute:', err);
    }
  }
  res.json({received: true});
});
```

## Adyen

### Webhook Event: `NOTIFICATION_OF_CHARGEBACK` and `CHARGEBACK`

Adyen sends `NOTIFICATION_OF_CHARGEBACK` when the bank notifies them, and `CHARGEBACK` upon the actual debit. Processing either/both is required for best feedback loop timing.

```javascript
// Express example
app.post('/webhooks/adyen', express.json(), (req, res) => {
  const notificationRequest = req.body;
  
  for (const item of notificationRequest.notificationItems) {
    const {NotificationRequestItem: {eventCode, pspReference}} = item;
    if (eventCode === 'NOTIFICATION_OF_CHARGEBACK' || eventCode === 'CHARGEBACK') {
      // Call reCAPTCHA Annotate Assessment with FRAUDULENT
    }
  }
  
  // Adyen requires a specific JSON response body or the literal string '[accepted]'
  res.json({notificationResponse: '[accepted]'});
});
```
