# Plantproxy

What is the problem? 

Github raw puml files (files within private repositories) come with an access token that expires after 7 days. 

Using the insecure (and confidentiallity busting) plantuml public service has the disadvantage that the images break after 7 days as a consequence.

We create a caching reverse proxy which generates the image and then keeps a copy which will be served by subsequent requests with identical parameters without re-sending the request to the upstream plantuml server. 

This solves the problem of expiring github raw tokens as we don't get plantuml to re-process the request with a stale token, we already have the output image in our proxy cache.



What we need

1. Basic implementation is working
  1. Module implementing github call is working
  2. Cache is working
   
TODO: 

* extract URL from call to endpoint
* docker compose to run this and the plantuml server
* tying the call to the web interface to the call to the plantuml server to render
* creating an elixir release 
* writing a doc 🤮
* deploy to kubernetes
* ...





