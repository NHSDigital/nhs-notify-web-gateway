exports.handler = (event, context, callback) => {
  const request = event.Records[0].cf.request;
  request.uri = request.uri.replace(/^\/templates\/files\//, "/");
  return callback(null, request);
};
