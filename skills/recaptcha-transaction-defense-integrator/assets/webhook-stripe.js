const express = require('express');
const stripe = require('stripe');

// --- Core Logic (Exportable for Serverless) ---

/**
 * Processes incoming Stripe webhook events.
 * @param {!object} headers The request headers, including 'stripe-signature'.
 * @param {string} body The raw request body.
 * @param {!object} env Environment variables containing secrets like STRIPE_SECRET_KEY and STRIPE_WEBHOOK_SECRET.
 * @returns {Promise<object>} An object indicating success, e.g., { received: true }.
 * @throws {Error} If the webhook signature is invalid or other errors occur during processing.
 */
async function processWebhook(headers, body, env) {
  const stripeClient = stripe(env.STRIPE_SECRET_KEY);
  const endpointSecret = env.STRIPE_WEBHOOK_SECRET;
  const sig = headers['stripe-signature'];
  
  let event;
  try {
    event = stripeClient.webhooks.constructEvent(body, sig, endpointSecret);
  } catch (err) {
    throw new Error(`Webhook Error: ${err.message}`);
  }

  if (event.type === 'charge.dispute.created') {
    const dispute = event.data.object;
    console.log('Dispute created:', dispute.id);
    
    // TODO: Look up assessmentName from DB using dispute.charge
    // TODO: Call annotateAssessment
  }

  return { received: true };
}

// --- Express Server (Default) ---

const app = express();
app.use(express.raw({type: 'application/json'}));

app.post('/webhooks/stripe', async (req, res) => {
  try {
    const result = await processWebhook(req.headers, req.body, process.env);
    res.json(result);
  } catch (err) {
    console.error(err);
    res.status(400).send(err.message);
  }
});

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => console.log(`Server listening on port ${PORT}`));

module.exports = { processWebhook, app };
