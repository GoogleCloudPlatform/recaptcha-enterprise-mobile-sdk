const express = require('express');
const { annotateAssessment } = require('./recaptcha-integration');

// --- Core Logic (Exportable for Serverless) ---

async function processWebhook(headers, body, env) {
  const notificationRequest = body;

  for (const item of notificationRequest.notificationItems) {
    const {NotificationRequestItem} = item;
    if (NotificationRequestItem.eventCode === 'NOTIFICATION_OF_CHARGEBACK') {
      console.log(
          'Adyen Chargeback received:', NotificationRequestItem.pspReference);
          
      // TODO: Look up assessmentName from your database using pspReference or merchantReference
      // Example: const assessmentName = await db.getAssessmentName(NotificationRequestItem.merchantReference);
      
      // if (assessmentName) {
      //   await annotateAssessment({
      //     assessmentName: assessmentName,
      //     annotation: 'FRAUDULENT',
      //     reasons: ['CHARGEBACK']
      //   });
      // }
    }
  }

  return {notificationResponse: '[accepted]'};
}

// --- Express Server (Default) ---

const app = express();
app.use(express.json());

app.post('/webhooks/adyen', async (req, res) => {
  try {
    const result = await processWebhook(req.headers, req.body, process.env);
    res.json(result);
  } catch (err) {
    console.error(err);
    res.status(500).send(err.message);
  }
});

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => console.log(`Server listening on port ${PORT}`));

module.exports = {
  processWebhook,
  app
};
