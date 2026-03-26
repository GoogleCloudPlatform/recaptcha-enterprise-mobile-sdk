// Tokens are single-use. You MUST generate a *fresh* token for every specific action.
// Do NOT cache the token on page load. Generate it just before the network request.
//
// EXAMPLE:
// document.getElementById('checkout-btn').addEventListener('click', async () => {
//   const token = await getRecaptchaToken('YOUR_SITE_KEY', 'checkout');
//   await fetch('/api/pay', {
//     method: 'POST',
//     body: JSON.stringify({ token, ...paymentData })
//   });
// });

/**
 * @param {string} siteKey - Your reCAPTCHA Enterprise Site Key
 * @param {string} action - The action name (e.g., 'checkout', 'login')
 * @returns {?Promise<string|null>} The reCAPTCHA token, or null if generation fails.
 */
async function getRecaptchaToken(siteKey, action) {
  try {
    // Note: grecaptcha.enterprise.execute returns a Promise
    const token = await grecaptcha.enterprise.execute(siteKey, {action: action});
    return token;
  } catch (error) {
    console.warn('reCAPTCHA verification failed (Fail Open):', error);
    return null; // Return null so your app can proceed (Fail Open)
  }
}

// EXAMPLE USAGE:
// const token = await getRecaptchaToken('YOUR_SITE_KEY', 'checkout');
// const response = await fetch('/api/pay', {
//   body: JSON.stringify({ token: token, ...paymentData })
// });
