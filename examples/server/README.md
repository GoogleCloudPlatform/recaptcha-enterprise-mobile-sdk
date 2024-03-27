# Demo Recaptcha Server

This folder holds the local server used to demo an integration with reCAPTCHA mobile
and a local running server.

## Install dependencies

To install all the dependencies of this server please run:

```
pip3 install -r requirements.txt
```

## How to use it

Change the value of the fields `USER_GUARD_CLOUD_PROJECT_NUMBER` and `USER_GUARD_API_KEY` with
the ones that that you will be used for retrieving assessments.

After all changes run:

```
python3 main.py
```