const { RecaptchaEnterpriseServiceClient } = require('@google-cloud/recaptcha-enterprise');

/**
 * Safely extracts a string token from a request body, 
 * handling cases where multiple tokens might be sent as an array.
 * @param {!object} reqBody The request body.
 * @return {string|undefined} The reCAPTCHA token, or undefined if not found.
 */
function getRecaptchaToken(reqBody) {
  const token = reqBody['g-recaptcha-response'];
  if (Array.isArray(token)) {
    // If multiple tokens found (e.g. duplicate form fields), 
    // the last one is typically the most recent.
    return token[token.length - 1];
  }
  return token;
}

/**
 * Creates an assessment to analyze the risk of a UI action.
 * @param {{projectID: (string|undefined), siteKey: (string|undefined), token: string, transactionData: (!object|undefined), expectedAction: (string|null)}} params
 * @return {?Promise<?object>} A promise that resolves to the created Assessment object or null if an error occurred.
 */
async function createAssessment({
  projectID = process.env.CLOUD_PROJECT_ID,
  siteKey = process.env.RECAPTCHA_SITE_KEY,
  token = 'USER_RESPONSE_TOKEN',
  transactionData = {},
  expectedAction = null
}) {
  const client = new RecaptchaEnterpriseServiceClient();
  const projectPath = client.projectPath(projectID);

  const request = {
    assessment: {
      event: {
        token: token,
        siteKey: siteKey,
        transactionData: transactionData,
        expectedAction: expectedAction // Passed to API if needed, but mainly for client-side check
      },
    },
    parent: projectPath,
  };

  try {
    const [ response ] = await client.createAssessment(request);

    if (!response.tokenProperties.valid) {
      console.log("The CreateAssessment call failed because the token was: " +
          response.tokenProperties.invalidReason);
      return null;
    }

    if (expectedAction && response.tokenProperties.action !== expectedAction) {
        console.log(`The action attribute in your reCAPTCHA tag is: ${response.tokenProperties.action}`);
        console.log(`The action attribute in the reCAPTCHA tag does not match the action you are expecting to score: ${expectedAction}`);
        return null;
    }

    console.log("Assessment name: " + response.name);
    console.log("Transaction Verdict: " + response.riskAnalysis.reasons);
    
    return response;
  } catch (e) {
    console.error("CreateAssessment failed:", e);
    return null; 
  }
}

/**
 * Annotates a previously created assessment to provide feedback to reCAPTCHA.
 * This improves model accuracy over time (e.g., confirming fraud or legitimacy).
 * @param {{assessmentName: string, annotation: string, reasons: (!Array<string>|undefined)}} params
 * @return {!Promise<?object>} A promise that resolves to the AnnotateAssessmentResponse or null if an error occurred.
 */
async function annotateAssessment({ assessmentName, annotation, reasons = [] }) {
  const client = new RecaptchaEnterpriseServiceClient();
  const request = {
    name: assessmentName,
    annotation: annotation,
    reasons: reasons,
  };

  try {
    const [ response ] = await client.annotateAssessment(request);
    console.log(`Annotated assessment ${assessmentName} as ${annotation}`);
    return response;
  } catch (err) {
    console.error(`Error annotating assessment ${assessmentName}:`, err);
    return null;
  }
}

module.exports = { createAssessment, annotateAssessment, getRecaptchaToken };
