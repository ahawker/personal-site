---
layout: post
title: Adding Trello login support to Auth0
date: 2020-07-06 09:19:00-8000
author: me
category: writings
tags: [auth0, trello]
keywords: [auth0, trello]
---

At my company [Routegy](https://routegy.com), we use [Auth0](https://auth0.com) for identity management. While it is nice, in theory, to offload authn/authz to someone else so you can focus on building your product, integrating it does have a number of quirks.

In this instance, I was looking to support [Trello](https://trello.com) logins, which Auth0 doesn't support with a native social connection. A quick Google search yields this [community post](https://community.auth0.com/t/auth0-and-trello/17043) which recommends that you use the [Custom Social Connections](https://auth0.com/docs/extensions/custom-social-extensions) extension. This doesn't appear to work since Trello uses [OAuth 1.1](https://developer.atlassian.com/cloud/trello/guides/rest-api/authorization/) and the Custom Social Connections extension only appears to support OAuth 2.0.

After some further research, I thankfully came across documentation outlining Auth0 support for creating generic [OAuth 1](https://auth0.com/docs/connections/adding-generic-oauth1-connection) and [OAuth 2](https://auth0.com/docs/connections/social/oauth2) connections. This works by creating an Auth0 connection with OAuth 1.1 urls and writing a custom javascript function that takes information provided in the OAuth callback to create an Auth0 profile.

With some custom code, we should be able to support Trello logins. Let's dive in!

### Getting your Trello credentials

In order to create an OAuth 1.1 connection, you will need your **`client_id`** and **`client_secret`** pair for Trello. To get these, login to Trello and go to <https://trello.com/app-key>.

The **`client_id`** value will be the **`Key`** value found on this page.

The **`client_secret`** value will be found by clicking the **`Token`** URL found on that page. This will prompt you to give access to the Trello `Server Token` application. Granting access will display the value to use.

![](/assets/images/posts/trello-server-token.png)

### Creating a Trello connection

To create an arbitrary OAuth 1.1 connection in Auth0, we need to use the Auth0 Management API as there is no support for it in the management dashboard. If you don't already have one, check out the [official documentation](https://auth0.com/docs/api/management/v2/tokens) for more details on creating your Management API access token. Once created, this can be done with a simple `curl` command such as:

```bash
curl -X POST
     -H "Content-Type: application/json"
     -H 'Authorization: Bearer ${YOUR_AUTH0_MANAGEMENT_API_TOKEN}'
     -d @trello.json https://${YOUR_AUTH0_DOMAIN}/api/v2/connections
```

This creates an Auth0 connection using the JSON data stored in our local **`trello.json`** file. The contents of this file will change based on specifics to your account but will look something like:

```json
{
  "name": "trello",
  "strategy": "oauth1",
  "options": {
    "client_id": "${YOUR_TRELLO_CLIENT_ID}",
    "client_secret": "${YOUR_TRELLO_CLIENT_SECRET}",
    "requestTokenURL": "https://trello.com/1/OAuthGetRequestToken",
    "accessTokenURL": "https://trello.com/1/OAuthGetAccessToken",
    "userAuthorizationURL": "https://trello.com/1/OAuthAuthorizeToken?name=${APP_NAME}&scope=${SCOPE}&expiration=${EXPIRATION}",
    "scripts": {
      "fetchUserProfile": "${SCRIPT}"
    }
  },
    "enabled_clients": [
      "${AUTH0_CLIENT_1}",
      "${AUTH0_CLIENT_2}"
    ]
}
```

This file has a number of variables in it. Let's go through them one by one:

* **`${YOUR_TRELLO_CLIENT_ID}`** - The `client_id` value from Trello noted above.
* **`${YOUR_TRELLO_CLIENT_SECRET}`** - The `client_secret` value from Trello noted above.
* **`${APP_NAME}`** - The name of your Trello application, e.g. your company name.
* **`${SCOPE}`** - The OAuth scope your application is requesting. Comma-separated list of one or more of **read**, **write**, **account**.
* **`${EXPIRATION}`** - The lifetime of the token/secret Trello sends to Auth0, e.g. `never`.
* **`${SCRIPT}`** - The javascript function run to convert Trello information into an Auth0 profile. **See below**.
* **`${AUTH0_CLIENT_XYZ}`** - The ID's of all Auth0 Clients that should allow Trello login.

The Trello [official documentation](https://developer.atlassian.com/cloud/trello/guides/rest-api/authorization/) contains more information on the specific values provided like application name, scope, and expiration.

The javascript code for fetch user profile **`${SCRIPT}`** is:

```js
function (token, tokenSecret, ctx, cb) {
    var OAuth = new require('oauth').OAuth;
    var oauth = new OAuth(
      ctx.requestTokenURL,
      ctx.accessTokenURL,
      ctx.client_id,
      ctx.client_secret,
      '1.0A',
      null,
      'HMAC-SHA1'
    );

    oauth.get('https://api.trello.com/1/members/me', token, tokenSecret, function(e, b, r) {
        if (e) {
          return cb(e);
        }
        if (r.statusCode !== 200) {
          return cb(new Error('Failed to authenticate with Trello. Code: ' + r.statusCode));
        }

        var member = JSON.parse(b);

        var profile = {
          user_id: member.id,
          email: member.email,
          name: member.fullName,
          email_verified: member.confirmed,
          nickname: member.username,
          token: token,
          token_secret: tokenSecret
        };

        cb(null, profile);
    })
}
```

### Calling the Trello API on their behalf

Once the user logs in with the Trello Auth0 connection, you'll see the `token` and `tokenSecret` values stored on that user profile. These can be used to call the Trello API on behalf of the user. For example:

```python
from trello import TrelloClient

client = TrelloClient(
    api_key='${YOUR_TRELLO_CLIENT_ID}',
    api_secret='${YOUR_TRELLO_CLIENT_SECRET}',
    token='${TOKEN}',
    token_secret='${TOKEN_SECRET}'
)
```

The variables in this example are as follows:

* **`${YOUR_TRELLO_CLIENT_ID}`** - The `client_id` value from Trello noted above.
* **`${YOUR_TRELLO_CLIENT_SECRET}`** - The `client_secret` value from Trello noted above.
* **`${TOKEN}`** - The **`token`** value stored on the Auth0 user profile.
* **`${TOKEN_SECRET}`** - The **`tokenSecret`** value stored on the Auth0 user profile.

### Summary

In order to support Trello connections with Auth0, you must create a custom OAuth 1.1 connection with a custom javascript function that fetches Trello user information to create an Auth0 user profile.
