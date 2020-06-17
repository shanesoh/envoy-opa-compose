package envoy.authz

import input.attributes.request.http as http_request

default allow["allowed"] = false

# New headers that OPA adds
# -------------------------
# Try not to conflict with headers that are in the original request!
# Observed behavior - suppose original request has "User-Agent": "curl/7.58.0"
# If OPA returns "User-Agent": "Overwrite", the request going upstream will be
#   "User-Agent": "Overwrite"
# If OPA returns "user_agent": "Overwrite", the request going upstream will be
#   "User-Agent": "curl/7.58.0,Overwrite"
# Can't find documentation for this behaviour

allow["headers"] = {
	"X-Auth-User": "xxxxxxxxxx",
	"User-Agent": "Overwrite",
}

allow["allowed"] = true {
	http_request.method == "GET"
}
