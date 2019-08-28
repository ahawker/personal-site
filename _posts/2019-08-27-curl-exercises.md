---
layout: post
title: Curl Exercises (Solutions)
date: 2019-08-27 15:09:00-8000
author: me
category: writings
tags: [curl, julia evans, exercise]
---

Julia Evans has a new blog post up, [Curl Exercises](https://jvns.ca/blog/2019/08/27/curl-exercises/),  which landed on the front page of [Hacker News](https://news.ycombinator.com/item?id=20811829) today. [^1] In it, she brings up the idea of [deliberate practice](https://jamesclear.com/deliberate-practice-theory) and outlines 21 exercises to better familiarize yourself with [cURL](https://curl.haxx.se/).

[^1]: {-}
  Check out [jvns.ca](https://jvns.ca/) for more of her content, I highly recommend it!

I'm looking for a distraction from my current work with [terraform](https://www.terraform.io/), so let's shave this yak!

## Exercises

The following are my solutions for the 21 exercise questions. I'll try and go simply from memory; making note when I need to reference the [man page](https://curl.haxx.se/docs/manpage.html).

#1: Request [https://httpbin.org](https://httpbin.org)

```
⇒  curl https://httpbin.org

<!DOCTYPE html>
<html lang="en">
...
...
</html>
```

#2: Request [https://httpbin.org/anything](https://httpbin.org/anything). httpbin.org/anything will look at the request you made, parse it, and echo back to you what you requested. curl’s default is to make a GET request.

```json
⇒  curl https://httpbin.org/anything
{
  "args": {},
  "data": "",
  "files": {},
  "form": {},
  "headers": {
    "Accept": "*/*",
    "Host": "httpbin.org",
    "User-Agent": "curl/7.54.0"
  },
  "json": null,
  "method": "GET",
  "origin": "<redacted>",
  "url": "https://httpbin.org/anything"
}
```

#3: Make a POST request to [https://httpbin.org/anything](https://httpbin.org/anything)

[^-X]

[^-X]: {-}
  Here we're using the [-X](https://curl.haxx.se/docs/manpage.html#-X) option for specifying a custom HTTP method.

```json
⇒  curl -X POST https://httpbin.org/anything
{
  "args": {},
  "data": "",
  "files": {},
  "form": {},
  "headers": {
    "Accept": "*/*",
    "Content-Length": "0",
    "Host": "httpbin.org",
    "User-Agent": "curl/7.54.0"
  },
  "json": null,
  "method": "POST",
  "origin": "<redacted>",
  "url": "https://httpbin.org/anything"
}
```

#4: Make a GET request to [https://httpbin.org/anything](https://httpbin.org/anything), but this time add some query parameters (set value=panda).

```json
⇒  curl https://httpbin.org/anything\?value\=panda
{
  "args": {
    "value": "panda"
  },
  "data": "",
  "files": {},
  "form": {},
  "headers": {
    "Accept": "*/*",
    "Host": "httpbin.org",
    "User-Agent": "curl/7.54.0"
  },
  "json": null,
  "method": "GET",
  "origin": "<redacted>",
  "url": "https://httpbin.org/anything?foo=bar"
}
```

#5: Request google’s robots.txt file ([https://www.google.com/robots.txt](https://www.google.com/robots.txt))

```
⇒  curl https://www.google.com/robots.txt

User-agent: *
Disallow: /search
Allow: /search/about
Allow: /search/static
Allow: /search/howsearchworks
Disallow: /sdch
...
...
Sitemap: https://www.google.com/sitemap.xml
```

#6: Make a GET request to [https://httpbin.org/anything](https://httpbin.org/anything) and set the header User-Agent: elephant.

[^-H]

[^-H]: {-}
  Here we're using the [-H](https://curl.haxx.se/docs/manpage.html#-H) option for specifying a custom HTTP header.

```json
⇒  curl -H 'User-Agent: elephant' https://httpbin.org/anything
{
  "args": {},
  "data": "",
  "files": {},
  "form": {},
  "headers": {
    "Accept": "*/*",
    "Host": "httpbin.org",
    "User-Agent": "elephant"
  },
  "json": null,
  "method": "GET",
  "origin": "<redacted>",
  "url": "https://httpbin.org/anything"
}
```

#7: Make a DELETE request to [https://httpbin.org/anything](https://httpbin.org/anything)

[^-X]

[^-X]: {-}
  Here we're once again using the [-X](https://curl.haxx.se/docs/manpage.html#-X) option for specifying a custom HTTP method.

```json
⇒  curl -X DELETE https://httpbin.org/anything
{
  "args": {},
  "data": "",
  "files": {},
  "form": {},
  "headers": {
    "Accept": "*/*",
    "Host": "httpbin.org",
    "User-Agent": "curl/7.54.0"
  },
  "json": null,
  "method": "DELETE",
  "origin": "<redacted>",
  "url": "https://httpbin.org/anything"
}
```

#8: Make a POST request to [https://httpbin.org/anything](https://httpbin.org/anything) with the JSON body {"value": "panda"}

[^-d]

[^-d]: {-}
  Here we're using the [-d](https://curl.haxx.se/docs/manpage.html#-d) to send POST data to the server.

```json
⇒  curl -X POST https://httpbin.org/anything -d '{"value": "panda"}'
{
  "args": {},
  "data": "",
  "files": {},
  "form": {
    "{\"value\": \"panda\"}": ""
  },
  "headers": {
    "Accept": "*/*",
    "Content-Length": "18",
    "Content-Type": "application/json",
    "Host": "httpbin.org",
    "User-Agent": "curl/7.54.0"
  },
  "json": {
    "value": "panda"
  },
  "method": "POST",
  "origin": "<redacted>",
  "url": "https://httpbin.org/anything"
}
```

#9: Request [https://httpbin.org/anything](https://httpbin.org/anything) and also get the response headers

[^-i]

[^-i]: {-}
  Here we're using [-i](https://curl.haxx.se/docs/manpage.html#-i) to print the response headers. I had to reference the man pages for this one as I normally just use [-v](https://curl.haxx.se/docs/manpage.html#-v) whenever I'm debugging.

```json
⇒  curl -i https://httpbin.org/anything

HTTP/1.1 200 OK
Access-Control-Allow-Credentials: true
Access-Control-Allow-Origin: *
Content-Type: application/json
Date: Wed, 28 Aug 2019 00:46:22 GMT
Referrer-Policy: no-referrer-when-downgrade
Server: nginx
X-Content-Type-Options: nosniff
X-Frame-Options: DENY
X-XSS-Protection: 1; mode=block
Content-Length: 290
Connection: keep-alive

{
  "args": {},
  "data": "",
  "files": {},
  "form": {},
  "headers": {
    "Accept": "*/*",
    "Host": "httpbin.org",
    "User-Agent": "curl/7.54.0"
  },
  "json": null,
  "method": "GET",
  "origin": "<redacted>",
  "url": "https://httpbin.org/anything"
}
```

#10: Make the same POST request as the previous exercise, but set the Content-Type header to application/json (because POST requests need to have a content type that matches their body). Look at the json field in the response to see the difference from the previous one.

[^-H]

[^-H]: {-}
  Here we're using the [-H](https://curl.haxx.se/docs/manpage.html#-H) option for specifying a custom HTTP header.

```json
⇒  curl -X POST -H 'Content-Type: application/json' https://httpbin.org/anything -d '{"value": "panda"}'
{
  "args": {},
  "data": "{\"value\": \"panda\"}",
  "files": {},
  "form": {},
  "headers": {
    "Accept": "*/*",
    "Content-Length": "18",
    "Content-Type": "application/json",
    "Host": "httpbin.org",
    "User-Agent": "curl/7.54.0"
  },
  "json": {
    "value": "panda"
  },
  "method": "POST",
  "origin": "<redacted>",
  "url": "https://httpbin.org/anything"
}
```

#11: Make a GET request to [https://httpbin.org/anything](https://httpbin.org/anything) and set the header Accept-Encoding: gzip (what happens? why?)

[^-H]

[^-H]: {-}
  Here we're using the [-H](https://curl.haxx.se/docs/manpage.html#-H) option for specifying a custom HTTP header.

```json
⇒  curl -H 'Accept-Encoding: gzip' https://httpbin.org/anything
U�A� E����4
��ݹ0��PE�Q0���x�Zc���?3&H�0�'kb�����=�F�� [Jj�����(���-���ݰ���`�v~�z�i��\ ������`T,�jTN�%A'h�V㥥�T�]�=5������o�H�w1�1�b%g���[؞��9Ƈb���i���}��}uB%
```

#12: Put a bunch of a JSON in a file and then make a POST request to [https://httpbin.org/anything](https://httpbin.org/anything) with the JSON in that file as the body

First off, we need JSON. Let's grab some commit history of the repository for the codebase that generates this site using the GitHub API.

```bash
⇒  wget 'https://api.github.com/repos/ahawker/personal-site/commits?per_page=1' -O data.json
```

[^-d@]

[^-d@]: {-}
  Here we're once again using the [-d](https://curl.haxx.se/docs/manpage.html#-d) option for sending data to the server. If the value given starts with `@`, it should be preceded by a filename. cURL will then use the content of the file for POST data.

```json
⇒  curl -X POST https://httpbin.org/anything -d @data.json
{
  "args": {},
  "data": "",
  "files": {},
  "form": {
    "[  {    \"sha\": \"b5f2e7d3d78d55b6046e554bf0329082d04e62ce\",    \"node_id\": \"MDY6Q29tbWl0MjI1MzY1NjA6YjVmMmU3ZDNkNzhkNTViNjA0NmU1NTRiZjAzMjkwODJkMDRlNjJjZQ": "=\",    \"commit\": {      \"author\": {        \"name\": \"Andrew Hawker\",        \"email\": \"andrew.r.hawker@gmail.com\",        \"date\": \"2019-08-27T20:33:36Z\"      },      \"committer\": {        \"name\": \"Andrew Hawker\",        \"email\": \"andrew.r.hawker@gmail.com\",        \"date\": \"2019-08-27T20:33:46Z\"      },      \"message\": \"Exclude Makefile from jekyll build output\",      \"tree\": {        \"sha\": \"33a45d9727c740a205f677d4e50039c1d5d729f4\",        \"url\": \"https://api.github.com/repos/ahawker/personal-site/git/trees/33a45d9727c740a205f677d4e50039c1d5d729f4\"      },      \"url\": \"https://api.github.com/repos/ahawker/personal-site/git/commits/b5f2e7d3d78d55b6046e554bf0329082d04e62ce\",      \"comment_count\": 0,      \"verification\": {        \"verified\": false,        \"reason\": \"unsigned\",        \"signature\": null,        \"payload\": null      }    },    \"url\": \"https://api.github.com/repos/ahawker/personal-site/commits/b5f2e7d3d78d55b6046e554bf0329082d04e62ce\",    \"html_url\": \"https://github.com/ahawker/personal-site/commit/b5f2e7d3d78d55b6046e554bf0329082d04e62ce\",    \"comments_url\": \"https://api.github.com/repos/ahawker/personal-site/commits/b5f2e7d3d78d55b6046e554bf0329082d04e62ce/comments\",    \"author\": {      \"login\": \"ahawker\",      \"id\": 178002,      \"node_id\": \"MDQ6VXNlcjE3ODAwMg==\",      \"avatar_url\": \"https://avatars1.githubusercontent.com/u/178002?v=4\",      \"gravatar_id\": \"\",      \"url\": \"https://api.github.com/users/ahawker\",      \"html_url\": \"https://github.com/ahawker\",      \"followers_url\": \"https://api.github.com/users/ahawker/followers\",      \"following_url\": \"https://api.github.com/users/ahawker/following{/other_user}\",      \"gists_url\": \"https://api.github.com/users/ahawker/gists{/gist_id}\",      \"starred_url\": \"https://api.github.com/users/ahawker/starred{/owner}{/repo}\",      \"subscriptions_url\": \"https://api.github.com/users/ahawker/subscriptions\",      \"organizations_url\": \"https://api.github.com/users/ahawker/orgs\",      \"repos_url\": \"https://api.github.com/users/ahawker/repos\",      \"events_url\": \"https://api.github.com/users/ahawker/events{/privacy}\",      \"received_events_url\": \"https://api.github.com/users/ahawker/received_events\",      \"type\": \"User\",      \"site_admin\": false    },    \"committer\": {      \"login\": \"ahawker\",      \"id\": 178002,      \"node_id\": \"MDQ6VXNlcjE3ODAwMg==\",      \"avatar_url\": \"https://avatars1.githubusercontent.com/u/178002?v=4\",      \"gravatar_id\": \"\",      \"url\": \"https://api.github.com/users/ahawker\",      \"html_url\": \"https://github.com/ahawker\",      \"followers_url\": \"https://api.github.com/users/ahawker/followers\",      \"following_url\": \"https://api.github.com/users/ahawker/following{/other_user}\",      \"gists_url\": \"https://api.github.com/users/ahawker/gists{/gist_id}\",      \"starred_url\": \"https://api.github.com/users/ahawker/starred{/owner}{/repo}\",      \"subscriptions_url\": \"https://api.github.com/users/ahawker/subscriptions\",      \"organizations_url\": \"https://api.github.com/users/ahawker/orgs\",      \"repos_url\": \"https://api.github.com/users/ahawker/repos\",      \"events_url\": \"https://api.github.com/users/ahawker/events{/privacy}\",      \"received_events_url\": \"https://api.github.com/users/ahawker/received_events\",      \"type\": \"User\",      \"site_admin\": false    },    \"parents\": [      {        \"sha\": \"87a8dbf738918ef206f263e409cdba2ea49d6a3d\",        \"url\": \"https://api.github.com/repos/ahawker/personal-site/commits/87a8dbf738918ef206f263e409cdba2ea49d6a3d\",        \"html_url\": \"https://github.com/ahawker/personal-site/commit/87a8dbf738918ef206f263e409cdba2ea49d6a3d\"      }    ]  }]"
  },
  "headers": {
    "Accept": "*/*",
    "Content-Length": "3750",
    "Content-Type": "application/x-www-form-urlencoded",
    "Host": "httpbin.org",
    "User-Agent": "curl/7.54.0"
  },
  "json": null,
  "method": "POST",
  "origin": "<redacted>",
  "url": "https://httpbin.org/anything"
}
```

#13: Make a request to [https://httpbin.org/image](https://httpbin.org/image) and set the header ‘Accept: images/png’. Save the output to a PNG file and open the file in an image viewer. Try the same thing with with different Accept: headers.

[^-o]

[^-o]: {-}
  Here we're using the [-o](https://curl.haxx.se/docs/manpage.html#-o) option to specify the output of the command instead of `stdout`.

[^image.png]

```bash
⇒  curl -H 'Accept: image/png' https://httpbin.org/image -o image.png
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100  8090  100  8090    0     0  21910      0 --:--:-- --:--:-- --:--:-- 21924
```

[^image.png]: {-}
  Run `open image.png` to view the content. ![image.png](/assets/images/posts/httpbin-image.png)

#14: Make a PUT request to [https://httpbin.org/anything](https://httpbin.org/anything)

```json
⇒  curl -X PUT https://httpbin.org/anything
{
  "args": {},
  "data": "",
  "files": {},
  "form": {},
  "headers": {
    "Accept": "*/*",
    "Content-Length": "0",
    "Host": "httpbin.org",
    "User-Agent": "curl/7.54.0"
  },
  "json": null,
  "method": "PUT",
  "origin": "<redacted>",
  "url": "https://httpbin.org/anything"
}
```

#15: Request [https://httpbin.org/image/jpeg](https://httpbin.org/image/jpeg), save it to a file, and open that file in your image editor.

[^-o2]

[^-o2]: {-}
  Here we're once again using the [-o](https://curl.haxx.se/docs/manpage.html#-o) option to specify the output of the command instead of `stdout`.

[^image.jpeg]

```
⇒  curl  https://httpbin.org/image/jpeg -o image.jpeg
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100 35588  100 35588    0     0  74331      0 --:--:-- --:--:-- --:--:-- 74451
```

[^image.jpeg]: {-}
  Run `open image.jpeg` to view the content. ![image.jpeg](/assets/images/posts/httpbin-image.jpeg)

#16: Request [https://google.com](https://google.com). You’ll get an empty response. Get curl to show you the response headers too, and try to figure out why the response was empty.

[^-L]

[^-L]: {-}
  You'll need to use the [-L](https://curl.haxx.se/docs/manpage.html#-L) option if you want cURL to automatically follow a redirect.

```
⇒  curl -i https://google.com
HTTP/1.1 301 Moved Permanently
Location: https://www.google.com/
Content-Type: text/html; charset=UTF-8
Date: Wed, 28 Aug 2019 17:17:53 GMT
Expires: Fri, 27 Sep 2019 17:17:53 GMT
Cache-Control: public, max-age=2592000
Server: gws
Content-Length: 220
X-XSS-Protection: 0
X-Frame-Options: SAMEORIGIN
Alt-Svc: quic=":443"; ma=2592000; v="46,43,39"

<HTML><HEAD><meta http-equiv="content-type" content="text/html;charset=utf-8">
<TITLE>301 Moved</TITLE></HEAD><BODY>
<H1>301 Moved</H1>
The document has moved
<A HREF="https://www.google.com/">here</A>.
</BODY></HTML>
```

#17: Make any request to [https://httpbin.org/anything](https://httpbin.org/anything) and just set some nonsense headers (like panda: elephant)

```json
⇒  curl -H 'Panda: Elephant' https://httpbin.org/anything
{
  "args": {},
  "data": "",
  "files": {},
  "form": {},
  "headers": {
    "Accept": "*/*",
    "Host": "httpbin.org",
    "Panda": "Elephant",
    "User-Agent": "curl/7.54.0"
  },
  "json": null,
  "method": "GET",
  "origin": "<redacted>",
  "url": "https://httpbin.org/anything"
}
```

#18: Request [https://httpbin.org/status/404](https://httpbin.org/status/404) and [https://httpbin.org/status/200](https://httpbin.org/status/200). Request them again and get curl to show the response headers.

```
⇒  curl https://httpbin.org/status/404
⇒  curl -i https://httpbin.org/status/404
HTTP/1.1 404 NOT FOUND
Access-Control-Allow-Credentials: true
Access-Control-Allow-Origin: *
Content-Type: text/html; charset=utf-8
Date: Wed, 28 Aug 2019 17:21:25 GMT
Referrer-Policy: no-referrer-when-downgrade
Server: nginx
X-Content-Type-Options: nosniff
X-Frame-Options: DENY
X-XSS-Protection: 1; mode=block
Content-Length: 0
Connection: keep-alive
```

[^-i2]

[^-i2]: {-}
  Here we're once again using the [-i](https://curl.haxx.se/docs/manpage.html#-i) option to output the response headers.

```
⇒  curl https://httpbin.org/status/200
⇒  curl -i https://httpbin.org/status/200
HTTP/1.1 200 OK
Access-Control-Allow-Credentials: true
Access-Control-Allow-Origin: *
Content-Type: text/html; charset=utf-8
Date: Wed, 28 Aug 2019 17:22:12 GMT
Referrer-Policy: no-referrer-when-downgrade
Server: nginx
X-Content-Type-Options: nosniff
X-Frame-Options: DENY
X-XSS-Protection: 1; mode=block
Content-Length: 0
Connection: keep-alive
```

#19: Request [https://httpbin.org/anything](https://httpbin.org/anything) and set a username and password (with -u username:password)

[^-u]

[^-u]: {-}
  You'll need to use the [-u](https://curl.haxx.se/docs/manpage.html#-u) option to send a username/password for HTTP Basic Authentication.

```json
⇒  curl -u foo:bar https://httpbin.org/anything
{
  "args": {},
  "data": "",
  "files": {},
  "form": {},
  "headers": {
    "Accept": "*/*",
    "Authorization": "Basic Zm9vOmJhcg==",
    "Host": "httpbin.org",
    "User-Agent": "curl/7.54.0"
  },
  "json": null,
  "method": "GET",
  "origin": "<redacted>",
  "url": "https://httpbin.org/anything"
}
```

#20: Download the Twitter homepage ([https://twitter.com](https://twitter.com)) in Spanish by setting the Accept-Language: es-ES header.

```
⇒  curl -H 'Accept-Language: es-ES' https://twitter.com
<!DOCTYPE html>
<html lang="es" data-scribe-reduced-action-queue="true">
  <head>
...
...
  </body>
</html>
```

#21: Make a request to the Stripe API with curl. (see [https://stripe.com/docs/development](https://stripe.com/docs/development) for how, they give you a test API key). Try making exactly the same request to [https://httpbin.org/anything](https://httpbin.org/anything).

[^api-key]

[^api-key]: {-}
  The API Key used below is the fake one from the [Stripe Documentation](https://stripe.com/docs/development) page. Create a Stripe account and login to get your actual Test API Keys.

```json
⇒  curl https://httpbin.org/anything \
  -u sk_test_4eC39HqLyjWDarjtT1zdp7dc: \
  -d amount=999 \
  -d currency=usd \
  -d source=tok_visa \
  -d receipt_email="jenny.rosen@example.com"
{
  "args": {},
  "data": "",
  "files": {},
  "form": {
    "amount": "999",
    "currency": "usd",
    "receipt_email": "jenny.rosen@example.com",
    "source": "tok_visa"
  },
  "headers": {
    "Accept": "*/*",
    "Authorization": "Basic c2tfdGVzdF80ZUMzOUhxTHlqV0Rhcmp0VDF6ZHA3ZGM6",
    "Content-Length": "77",
    "Content-Type": "application/x-www-form-urlencoded",
    "Host": "httpbin.org",
    "User-Agent": "curl/7.54.0"
  },
  "json": null,
  "method": "POST",
  "origin": "<redacted>",
  "url": "https://httpbin.org/anything"
}
```

## Summary

It was nice to learn about the [-i](https://curl.haxx.se/docs/manpage.html#-i) option, even though I do have quite a bit of experience with cURL. I normally just use [-v](https://curl.haxx.se/docs/manpage.html#-v) which spits out quite a bit more debug output.

I'd be interested to know of tools/products that provide a set of [Kōan](https://en.wikipedia.org/wiki/K%C5%8Dan) style exercises instead of the traditional _First Start_ tutorial and _Feature_ pages/notices.
