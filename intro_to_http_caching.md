##### HTTP Caching

There are only two hard things in Computer Science: cache invalidation and naming things. -- Phil Karlton

```
/--------\        /--------\        /--------\
| client | <----> | akamai | <----> | origin |
\--------/        \--------/        \--------/
```

HTTP is the protocol of the web. It's a text-based request-reply protocol. Both the request and the reply include metadata in the form of headers. Some of the header information can be used by a caching intermediary, the Akamai CDN in this instance. The headers are a list of key-value pairs, so the foo header is the value indexed by the key 'foo'.

For caching related stuff, we are mostly interested in the cache-control and expires headers.

The cache-control header contains several directives. The first specifies whether the content is 'public' or 'private'. If it's public then it can be cached by the CDN, but if it's private then it can only be cached by the browser. The second directive specifies one of three possibilities: 'no-store', 'must-revalidate' or 'no-cache'.

If the content is no-store then it cannot be cached at all. If the content is must-revalidate then the CDN will only respond with a cached copy of the content if the cache is not stale (according to the max-age or s-maxage directive). If the content is no-cache then the etag header is used to check that it's fresh. A round-trip to the server is necessary but if the etag has not changed (the 304 Not Modified case) then the cache can provide the content.

Whilst the max-age and s-maxage headers stipulate for how long the content can be cached, etags are different in that they are deliberately opaque. Etags are typically just a hash of the content itself, so they look like gibberish. They only provide validation, not any information about when to refresh the cache. The expires header is the most informative in a way, though it will hardly ever be correct because one cannot simply look in to the future to see when content will expire!

The expires and pragma headers have not really been obsoleted. For instance, on the basis of the expires header, the browser may choose to serve content from the cache straight away, without validating the etag, thus saving on a round-trip to the server.

References

 - Great article from the KeyCDN.com blog: https://www.keycdn.com/blog/a-guide-to-http-cache-headers/
 - Answers on StackOverflow: http://stackoverflow.com/a/500103,    http://stackoverflow.com/a/19938619
 - Detailed article from Google Developers:     https://developers.google.com/web/fundamentals/performance/optimizing-content-efficiency/http-caching
