---
name: gen-http
description: >-
  Generate ElasticVue Elasticsearch requests and humao.rest-client .http
  snippets. Never use curl unless asked. Use when the user runs /gen-http or
  asks for REST Client HTTP requests.
disable-model-invocation: true
---

# ElasticVue and REST Client

When generating Elasticsearch queries or HTTP requests, follow this file. Never generate `curl` unless the user explicitly asks for it.

## Elasticsearch (ElasticVue)

Every generated Elasticsearch request must be paste-ready for ElasticVue. Use this shape only:

```
<METHOD> <index>[/<optional _search|_doc|_bulk|...>]
<optional request body>
```

- No scheme, host, port, or leading slash on the path.
- Fence the snippet as `http`.
- Put the JSON/NDJSON body on the next line when present. Omit the body when there is none.
- Prefer `POST` for `_search` when a body is present (ElasticVue mishandles GET bodies).

```http
PUT hsk_catalog_blog_article
{
  "settings": {
    "number_of_shards": 1,
    "number_of_replicas": 1
  },
  "mappings": {
    "dynamic": false,
    "properties": {
      "id": { "type": "long" },
      "language_code": { "type": "keyword" }
    }
  }
}
```

```http
POST hsk_catalog_blog_article/_search
{
  "query": {
    "term": { "language_code": "en" }
  }
}
```

```http
GET hsk_catalog_blog_article/_doc/1
```

```http
POST hsk_catalog_seo/_bulk
{"index":{}}
{"page":"blog_home_page","platform":"web"}
{"index":{}}
{"page":"blog_article_page","platform":"web"}
```

Do not generate:

```http
PUT http://localhost:9200/hsk_catalog_blog_article
PUT /hsk_catalog_blog_article
```

## HTTP (humao.rest-client)

Every generated HTTP API request must follow [REST Client](https://github.com/Huachao/vscode-restclient) `.http` syntax so it can be sent from the editor.

- File variables: `@name = value` on its own line; reference as `{{name}}`.
- Separate requests with `###`.
- Request line: `METHOD {{base_url}}/path HTTP/1.1`.
- Split query params onto following lines starting with `?` then `&`.
- Headers follow the request line until the first blank line. Blank line, then body.
- Name a request with `# @name requestName` immediately above the request line when a later request needs its response.
- Chain values with `@var = {{requestName.response.body.$.jsonPath}}` (JSONPath after `$.`).
- Comments start with `#` or `//`.
- When editing this repo's `.http` files, reuse existing env vars such as `{{host}}` and `{{catalog_path}}`.

```http
@base_url={{host}}{{catalog_path}}

###
GET {{base_url}}/api/v1/w/blog/article
?id=40 HTTP/1.1
Accept: application/json
X-Language: en
X-Platform: web
X-Timezone: Asia/Bangkok
```

```http
@auth_base_url={{host}}{{hsk_auth_path}}
@token_base_url={{host}}{{hsk_token_path}}
@device_id=ce27ca74-5160-47ea-829c-529afc7144e3
@email=hsksg@yopmail.com
@password=12@3456Aa@
@client_id=hasaki-web
@code_challenge=ZTL74W1a8HvRZTtP94jRj4IMzR-B33TGcULE-PS-k4U
@code_verifier=JMUyrZEmj.CAT3TgM9eypOv4n8S_2ncIVtdrI0lSQ8xwu.lr4HcH1F2O4tT2fUmMIaTdVEqMViwWkHvfNKStECWkza45~42Y5WTnoTUwL3PoBolAKYD7uVP7MKPp7kLh

###
# @name login
POST {{auth_base_url}}/customer/api/v1/auth/login HTTP/1.1
Content-Type: application/json
X-Device-Id: {{device_id}}

{
  "email": {
    "method": "PASSWORD",
    "email": "{{email}}",
    "password": "{{password}}"
  },
  "code_challenge": "{{code_challenge}}"
}

###
@authorization_code = {{login.response.body.$.data.authorization_code}}

# @name generateToken
POST {{token_base_url}}/customer/api/v1/token/token HTTP/1.1
Content-Type: application/json
X-Device-Id: {{device_id}}

{
  "authorization_code": "{{authorization_code}}",
  "client_id": "{{client_id}}",
  "code_verifier": "{{code_verifier}}"
}

###
@bearer_token = {{generateToken.response.body.$.data.access_token}}

# @name generalInfo
GET {{auth_base_url}}/customer/api/v1/user/general-info HTTP/1.1
X-Device-ID: {{device_id}}
Authorization: Bearer {{bearer_token}}
```
