// This is a Cloudfront Function, not a Lambda
// https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/functions-event-structure.html
// https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/functions-javascript-runtime-features.html
// https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/service_code_examples_cloudfront_functions_examples.html

function handler(event) {
  const request = event.request;
  request.uri = request.uri.replace(/^\/templates\/files\//, "/");
  return request;
}

// Export statements are not allowed in the CloudFront runtime
// console.error is undefined in the runtime.
// This check allows the function to be exported for unit tests
if (console.error) {
  exports.handler = handler;
}
