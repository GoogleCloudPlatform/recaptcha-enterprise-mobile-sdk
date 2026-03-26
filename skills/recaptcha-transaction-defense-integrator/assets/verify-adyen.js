/**
 * Temporary verification script for webhook-adyen.js
 * Parses a mock Adyen NOTIFICATION_OF_CHARGEBACK payload.
 */

const Module = require('module');
const originalRequire = Module.prototype.require;

Module.prototype.require = function(request) {
  if (request === 'express') {
    const expressMock = function() {
      return {
        use: () => {},
        post: () => {},
        listen: () => {}
      };
    };
    expressMock.json = () => {};
    return expressMock;
  }
  if (request === './recaptcha-integration') {
     return {
         annotateAssessment: async () => { console.log('Mocked annotateAssessment called'); }
     };
  }
  return originalRequire.apply(this, arguments);
};

const { processWebhook } = require('./webhook-adyen.js');


async function runTest() {
  console.log('--- Testing Adyen Webhook Parsing ---');
  
  // Standard Adyen payload structure
  const mockPayload = {
    "live": "false",
    "notificationItems": [
      {
        "NotificationRequestItem": {
          "eventCode": "NOTIFICATION_OF_CHARGEBACK",
          "pspReference": "test_psp_987654321",
          "merchantReference": "order_123"
        }
      },
      {
        "NotificationRequestItem": {
          "eventCode": "AUTHORISATION",
          "pspReference": "test_psp_111111111"
        }
      }
    ]
  };

  try {
    let loggedChargeback = false;
    const originalLog = console.log;
    
    // Intercept console.log to verify it parses the correct pspReference
    console.log = (...args) => {
      const msg = args.join(' ');
      if (msg.includes('Adyen Chargeback received:') && msg.includes('test_psp_987654321')) {
        loggedChargeback = true;
      }
      originalLog(...args); 
    };

    const result = await processWebhook({}, mockPayload, process.env);
    
    // Restore console.log
    console.log = originalLog;

    const acceptedValid = result.notificationResponse === '[accepted]';

    if (acceptedValid && loggedChargeback) {
      console.log('\n✅ TEST PASSED: Adyen webhook parsed correctly and responded [accepted].');
    } else {
      console.log('\n❌ TEST FAILED');
      console.log(`- Responded [accepted]? ${acceptedValid}`);
      console.log(`- Matched Chargeback event logic? ${loggedChargeback}`);
      process.exit(1);
    }
  } catch (e) {
    console.error('\n❌ TEST ERRORED:', e);
    process.exit(1);
  }
}

runTest();
