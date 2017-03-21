# Okta Auth Proxy

The idea is that you run this along-side an nginx instance, and it'll handle authentication for you for an application or page that doesn't understand SAML or okta.

# Configuration

Set the following environment variables

* SSO\_TARGET\_URL: the target url specified in okta
* SSO\_ISSUER: the accepted audience in okta
* PROXY\_TARGET: the address of the target application you are authing for
* CERT\_PATH: Path to the certificate provided by Okta
* COOKIE\_SECRET: a secure random secret for the cookie
* COOKIE\_DOMAIN: The domain to use for the cookie
* SESSION\_EXPIRE: Idle session expiration time in seconds

If okta authentication succeeds, a cookie will be created and stored for the session. All requests are proxied through proxy target if authentication succeeds.

The proxy target should be set as an internal server in nginx, so that it can only be accessed through a local referral. See the example nginx configuration provided

The following variables are optional:

* AUTH\_DOMAIN: the local address of this authentication app (change if not 'localhost')
* COOKIE\_SECRET: a random secret will be generated at runtime if this is not set. If you need to avoid reauthenticating each time okta-auth-proxy is restarted for some reason, set this to a fixed value.
* DEBUG: set this to anything to debug logging

**Note:** Ensure the protocol in okta matches the protocol of your app (http/https)

```bash
export SSO_TARGET_URL=https://company.okta.com/app/company_project_1/hXk5d47tkNkB0x7/sso/saml
export AUTH_DOMAIN=http://localhost:3311
export PROXY_TARGET=http://127.0.0.1:7000
bundle exec okta-auth-proxy serve
```

# Credits

Based on work of
* https://github.com/dalehamel (original author)
* https://github.com/stecman (fork author)

This was inspired by smashing the ideas from projects together:

* https://antoineroygobeil.com/blog/2014/2/6/nginx-ruby-auth/
* https://github.com/ThoughtWorksInc/okta-samples/tree/master/okta-ruby-sinatra
