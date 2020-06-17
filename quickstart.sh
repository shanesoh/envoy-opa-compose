#!/bin/bash

client_secret="$1"
if [ -z "$client_secret" ]; then
    echo "Usage: $0 <client_secret (from keycloak)>"
    exit 1
fi

echo "Use client credentials flow to get a token:"

token=$(curl -X POST --silent -H "Content-Type: application/x-www-form-urlencoded" --user "httpbin:$client_secret" http://keycloak.localhost/auth/realms/applications/protocol/openid-connect/token -d "grant_type=password&username=user0&password=password&scope=httpbin" | jq -r '.access_token')

if [ "$token" = "null" ]; then
    echo "Perhaps the account is not fully set up. Look up user0 at keycloak and remove any Required User Actions"
    exit 1
fi

echo "$token"

echo "$token" | jq -R 'split(".") | .[1] | @base64d | fromjson'

echo "Trying the happy case - request is handled correctly"

curl -H "Authorization: Bearer $token" -X GET -s http://httpbin.localhost/get

echo "POST is not allowed - 403"

curl -H "Authorization: Bearer $token" -X POST -s -o /dev/null -w "%{http_code}\n" http://httpbin.localhost/post

echo "No access token - 401"

curl -X GET -s -o /dev/null -w "%{http_code}\n" http://httpbin.localhost/

echo "Expired token/token for different audience - 401"

curl -H "Authorization: Bearer eyJhbGciOiJSUzI1NiIsInR5cCIgOiAiSldUIiwia2lkIiA6ICIxM28yajc1VlRPUU5rWUhEcWxIUEltYjVaQ21IbFp4bzZaTzJNOXMyTl9VIn0.eyJleHAiOjE1OTExNTkwMDEsImlhdCI6MTU5MTE1ODcwMSwiYXV0aF90aW1lIjoxNTkxMTU4NzAxLCJqdGkiOiJlY2U2ZDViMi04MWVmLTQxZWYtODc4OS04ZDE0ZDNiMjg5NjEiLCJpc3MiOiJodHRwczovL2tleWNsb2FrLmxvY2FsaG9zdC9hdXRoL3JlYWxtcy9hcHBsaWNhdGlvbnMiLCJhdWQiOiJmb28iLCJzdWIiOiI0YzBkNDU1ZC00YmZlLTQyZjItYTlkNC02MDJiNDk0Y2NjYzAiLCJ0eXAiOiJCZWFyZXIiLCJhenAiOiJmb28iLCJzZXNzaW9uX3N0YXRlIjoiZGJiZDhkNDgtMGIzZC00ZTZkLWIzZDQtMjI5Yjc0Y2RlZTQ2IiwiYWNyIjoiMSIsInNjb3BlIjoib3BlbmlkIGZvbyBwcm9maWxlIGVtYWlsIiwiZW1haWxfdmVyaWZpZWQiOmZhbHNlLCJuYW1lIjoiVXNlciBaZXJvIiwicHJlZmVycmVkX3VzZXJuYW1lIjoidXNlcjAiLCJnaXZlbl9uYW1lIjoiVXNlciIsImZhbWlseV9uYW1lIjoiWmVybyIsImVtYWlsIjoidXNlcjBAbWFpbC5jb20ifQ.fsKy6fTCifKsOnznQHJEGWd2aY3TbKbiwrbOEV4bwevPkt_ths7kS3sWPbGCi9hphZQ9zup_wJYKudwpluyoDk5YIbBrwPUpu4P6Ocist5-oGvlAbUhVyIy8Ylh2gs3hLLnUPYdg0Cj19c467Yw1fiX7kdYFumr9AOB0arlvzsdYKNewls6-AZqTvICmhXWplHcu8DQRtinSf6vTnCLcqesc_PB-udWYmednT5CxZxcYQkWfVvyAN7EQa22dUXLTHfOKwF2csIsTBrn21xvVbBcTfbDZDfCR3UXrZ2AQLYPxkaUAxslW9zbyenQhSMeQhTZFfIUjp8ipS7AroEmviw" -X GET -s -o /dev/null -w "%{http_code}\n" http://httpbin.localhost/
