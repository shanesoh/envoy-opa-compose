# Using Envoy external authorization with Open Policy Agent

This project demonstrates how to use Envoy's external authorization filter with Open Policy Agent as the authorization
service to enforce security policies for all API requests received by Envoy.

Based on [this OPA tutorial](https://www.openpolicyagent.org/docs/latest/envoy-authorization/) using docker-compose
instead of Kubernetes.

This is meant for dockerized services (in a non-k8s environment) to easily leverage OPA for authorization.

*Disclaimer: This example project was initially created when there was lack of documentation on how to use the
`ext_authz` filter with OPA. Specifically there was a lack of sample code to run using docker-compose. There has
since been updated documentation and sample code in the [official
docs](https://www.envoyproxy.io/docs/envoy/latest/start/sandboxes/ext_authz). Do check that out instead!*

## Usage

Run `docker-compose up` to start services.

A toy `policy.rego` file is used to only permit GET requests, i.e. `curl -X GET http://localhost:8080/anything` should
work but `curl -X POST http://localhost:8080/anything` should fail.

Environment variables `SERVICE_NAME` and `SERVICE_PORT` refers to the service Envoy is proxying. These env variables
will replace the variables in `envoy.yaml`. See `./compose/envoy/entrypoint.sh` for more details.
