const crypto = require('crypto');
const queryString = require('query-string');

let response;

/**
 *
 * Event doc: https://docs.aws.amazon.com/apigateway/latest/developerguide/set-up-lambda-proxy-integrations.html#api-gateway-simple-proxy-for-lambda-input-format
 * @param {Object} event - API Gateway Lambda Proxy Input Format
 *
 * Context doc: https://docs.aws.amazon.com/lambda/latest/dg/nodejs-prog-model-context.html
 * @param {Object} context
 *
 * Return doc: https://docs.aws.amazon.com/apigateway/latest/developerguide/set-up-lambda-proxy-integrations.html
 * @returns {Object} object - API Gateway Lambda Proxy Output Format
 *
 */
exports.lambdaHandler = async (event, context) => {
    try {
      const json = validateJSON(event);

      const renderCSV = (key) => {
        if (json[key] && json[key].length > 0) {
          message = Object.keys(json[key][0]).join(",") + "\n";
          message += json[key].map(item => Object.values(item).join(",")).join("\n");
        } else {
          message = `${key.charAt(0).toUpperCase() + key.slice(1)} report requested, but no ${key} were in the query.\n\n`
          message += "Full query:\n\n"
          message += json;
        }
      }

      let message;

      if (json.type == "learners") {
        renderCSV("learners");
      } else if (json.type == "users") {
        renderCSV("users");
      } else {
        throw new Error("Demo report must be called from learner or user report page");
      }


      response = {
        statusCode: 200,
        body: message
      }
    } catch (err) {
      console.log(err);
      response = {
        statusCode: 500,
        body: `${err.toString()}\n\n${err.stack}`
      }
    }

    return response
};

function validateJSON(event) {
  if (!event.body) {
    throw new Error("Missing post body in request")
  }

  const body = queryString.parse(event.body);
  let json = body.json;
  if (!json) {
    throw new Error("Missing json body parameter");
  }

  const signature = body.signature;
  if (!signature) {
    throw new Error("Missing signature body parameter");
  }

  const hmac = crypto.createHmac('sha256', process.env.JWT_HMAC_SECRET);
  hmac.update(json);
  const signatureBuffer = new Buffer.from(signature);
  const digestBuffer = new Buffer.from(hmac.digest('hex'));

  if ((signatureBuffer.length !== digestBuffer.length) || !crypto.timingSafeEqual(signatureBuffer, digestBuffer)) {
    console.log("digestBuffer", digestBuffer.toString())
    throw new Error(`Invalid signature for json parameter.
        Either the report's JwtHmacSecret is incorrectly set, or the request JSON is not signed corrently.`);
  }

  try {
    json = JSON.parse(json);
  } catch (e) {
    throw new Error("Unable to parse json parameter");
  }

  return json;
}