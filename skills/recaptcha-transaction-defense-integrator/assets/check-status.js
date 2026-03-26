const { RecaptchaEnterpriseServiceClient } = require('@google-cloud/recaptcha-enterprise');

// Optionally load .env file if the user has dotenv installed
try {
  require('dotenv').config();
} catch (e) {
  // Silent fail: User might be passing vars directly via CLI
}

/**
 * Fetches and displays reCAPTCHA Enterprise metrics for the configured project and site key.
 * Requires CLOUD_PROJECT_ID and RECAPTCHA_SITE_KEY environment variables to be set.
 */
async function checkStatus() {
  const client = new RecaptchaEnterpriseServiceClient();
  const projectID = process.env.CLOUD_PROJECT_ID;
  const siteKey = process.env.RECAPTCHA_SITE_KEY;

  if (!projectID || !siteKey) {
    console.error('❌ Error: Missing required environment variables.');
    console.error('Usage:');
    console.error('  CLOUD_PROJECT_ID=my-project RECAPTCHA_SITE_KEY=my-key node check-status.js');
    console.error('  (Alternatively, create a .env file and install the `dotenv` package)');
    return;
  }

  const metricsName = `projects/${projectID}/keys/${siteKey}/metrics`;
  console.log(`Fetching metrics for: ${metricsName}`);

  try {
    const [metrics] = await client.getMetrics({ name: metricsName });

    console.log('\n--- reCAPTCHA Integration Status ---');
    console.log(`Start Time: ${metrics.startTime ? metrics.startTime.seconds : 'N/A'}`);
    console.log(`Score Metrics: ${metrics.scoreMetrics ? metrics.scoreMetrics.length : 0} days of data`);
    console.log(`Challenge Metrics: ${metrics.challengeMetrics ? metrics.challengeMetrics.length : 0} days of data`);

    if (metrics.scoreMetrics && metrics.scoreMetrics.length > 0) {
      const latest = metrics.scoreMetrics[0];
      console.log('\nLatest Score Distribution:');
      console.log(JSON.stringify(latest.overallMetrics.scoreBuckets, null, 2));
    } else {
      console.log('\nNo score metrics found yet. (Data can take up to 24h to appear)');
    }
  } catch (err) {
    console.error('Error fetching metrics:', err.message);
  }
}

checkStatus();
