package envoy.authz

import input.attributes.request.http as http_request

default allow["allowed"] = false

# New headers that OPA adds. If this is in conflict with those of the original
#   request, OPA's version takes precedence. Envoy will title-case and replace
#   underscores with dashes before overriding headers in original request
allow["headers"] = {
	"X-Auth-User": "xxxxxxxxxx",
	"user_agent": "MMINEEE",
}

allow["allowed"] = true {
	http_request.method == "GET"
}
