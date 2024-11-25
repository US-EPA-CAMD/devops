
/**
  ECMPS 2.0 backend-apis (e.g. easey-camd-services) require two types of authentications: 1) 'auth_token' and 2) 'client_token'.
  But, Zap does not have the capability process each endpoint, identify the required authentication type, and set the
  appropriate headers. This script is a workaround to set the authentication headers based on the OpenAPI spec.
  The api-full-scan-with-auth.yml workflow grabs the swagger-json spec from the swagger endpoint and then saves it in
  the local file system. Then it passes the path to the spec as an environment variable to this script for processing.
  This script reads the OpenAPI spec from the file system and extracts the security requirements for each endpoint.
  It then sets the appropriate authentication headers based on the security requirements.

  Note:
   This script is a JavaScript script, but it runs within the ZAP (OWASP Zed Attack Proxy)
   environment, which uses the Nashorn JavaScript engine. Nashorn allows JavaScript code to interoperate with
   Java classes seamlessly (and hence some Java looking imports below).
 */

var BufferedReader = Java.type('java.io.BufferedReader');
var InputStreamReader = Java.type('java.io.InputStreamReader');
var FileInputStream = Java.type('java.io.FileInputStream');
var Paths = Java.type('java.nio.file.Paths');
var Charset = Java.type('java.nio.charset.StandardCharsets');

var authMapping = {};

function parseOpenApiSpec() {
  var openApiSpecPath = java.lang.System.getenv('OPENAPI_SPEC_PATH') || '/zap/wrk/openapi-spec.json';
  var filePath = Paths.get(openApiSpecPath);
  var inputStream = new FileInputStream(filePath.toFile());
  var reader = new BufferedReader(new InputStreamReader(inputStream, Charset.forName('UTF-8')));
  var sb = '';
  var line;
  while ((line = reader.readLine()) != null) {
    sb += line;
  }
  reader.close();
  inputStream.close();

  var openApi = JSON.parse(sb);

  var paths = openApi.paths;
  for (var endpoint in paths) {
    var methods = paths[endpoint];
    for (var method in methods) {
      var operation = methods[method];
      var security = operation.security || openApi.security || [];
      var requiresAuthToken = false;
      var requiresClientToken = false;

      for (var i = 0; i < security.length; i++) {
        var schemes = security[i];
        if (schemes['Token']) {
          requiresAuthToken = true;
        }
        if (schemes['ClientToken']) {
          requiresClientToken = true;
        }
      }

      // Normalize endpoint path by replacing path parameters with placeholders
      var normalizedEndpoint = endpoint.replace(/\{[^}]+\}/g, '{}');

      // Build the key as method + normalized endpoint
      var key = method.toUpperCase() + ' ' + normalizedEndpoint;
      if (requiresClientToken) {
        authMapping[key] = 'client_token';
      } else if (requiresAuthToken) {
        authMapping[key] = 'auth_token';
      } else {
        authMapping[key] = 'none';
      }
    }
  }
}

function normalizePath(path) {
  // Remove query parameters
  var index = path.indexOf('?');
  if (index !== -1) {
    path = path.substring(0, index);
  }

  // Replace path parameters with placeholders
  path = path.replace(/\/\d+/g, '/{}'); // Replace numeric IDs
  path = path.replace(/\/[^\/]+/g, function(segment) {
    if (segment.match(/^\/[a-zA-Z0-9\-_]+$/)) {
      return segment;
    } else {
      return '/{}';
    }
  });

  return path;
}

function sendingRequest(msg, initiator, helper) {
  // 'initiator' and 'helper' parameters are required by ZAP's scripting API but are not used in this script.

  if (Object.keys(authMapping).length === 0) {
    parseOpenApiSpec();
  }

  var requestMethod = msg.getRequestHeader().getMethod();
  var requestUri = msg.getRequestHeader().getURI();
  var path = requestUri.getPath();
  var normalizedPath = normalizePath(path);

  // Build the key as method + normalized path
  var key = requestMethod + ' ' + normalizedPath;
  var authType = authMapping[key] || 'none';

  var headers = msg.getRequestHeader();
  // Always set the 'x-api-key' header
  headers.setHeader('x-api-key', java.lang.System.getenv('X_API_KEY'));

  if (authType === 'auth_token') {
    // Set 'Authorization' header with 'auth_token'
    headers.setHeader('Authorization', 'Bearer ' + java.lang.System.getenv('AUTH_TOKEN'));
    // Remove 'x-client-id' header if present
    headers.setHeader('x-client-id', null);
  } else if (authType === 'client_token') {
    // Set 'Authorization' header with 'client_token'
    headers.setHeader('Authorization', 'Bearer ' + java.lang.System.getenv('CLIENT_TOKEN'));
    // Set 'x-client-id' header
    headers.setHeader('x-client-id', java.lang.System.getenv('SCAN_CLIENT_ID'));
  } else {
    // No 'Authorization' header needed
    headers.setHeader('Authorization', null);
    headers.setHeader('x-client-id', null);
  }

  // Update the request headers
  msg.setRequestHeader(headers);
}

function responseReceived(msg, initiator, helper) {
  // No action required on response received
}
