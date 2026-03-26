# A library of agent skills for integrating reCAPTCHA to your websites and apps

## About

LLMs have fixed knowledge, being trained at a specific point in time. Software
dev is fast paced and changes often, where new libraries are launched every day
and best practices evolve quickly.

This leaves a knowledge gap that language models can't solve on their own. For
example, models don't know about themselves when they're trained, and they
aren't necessarily aware of subtle changes in best practices (like [thought
circulation](https://ai.google.dev/gemini-api/docs/thinking#signatures)) or SDK
changes.

[Skills](https://agentskills.io/) are a lightweight technique for adding
relevant context to your agents. This repo contains skills related to building
apps powered by the Gemini API.

## Skills in this repo

| Skill | Description |
| :--- | :--- |
| [`recaptcha-transaction-defense-integrator`](skills/recaptcha-transaction-defense-integrator) | Skill for integrating reCAPTCHA Enterprise Transaction Defense and automating ground truth via PSP chargeback webhooks (Stripe, Adyen). |

## Installation

You can browse and install skills using either the [Vercel skills CLI](https://skills.sh) or the [Context7 skills CLI](https://context7.com).

### Using [Vercel skills CLI](https://skills.sh)

```sh
# Interactively browse and install skills.
npx skills add GoogleCloudPlatform/recaptcha-enterprise-mobile-sdk --list

# Install a specific skill (e.g., gemini-api-dev).
npx skills add GoogleCloudPlatform/recaptcha-enterprise-mobile-sdk --skill recaptcha-transaction-defense-integrator --global
```

### Using [Context7 skills CLI](https://context7.com)

```sh
# Interactively browse and install skills.
npx ctx7 skills install /GoogleCloudPlatform/recaptcha-enterprise-mobile-sdk

# Install a specific skill (e.g., vertex-ai-api-dev).
npx ctx7 skills install /GoogleCloudPlatform/recaptcha-enterprise-mobile-sdk recaptcha-transaction-defense-integrator
```

## Disclaimer

This is not an officially supported Google product. The skills and sample code under this subfolder are not
eligible for the [Google Open Source Software Vulnerability Rewards
Program](https://bughunters.google.com/open-source-security).