const axios = require('axios');
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
      const body = validateJSON(event);

      if (body.jwt) {
        const {jwt, json} = body;
        const parsedJson = JSON.parse(json);
        const learnersApiUrl = parsedJson.learnersApiUrl;

        // create a copy of our request to display back to the user
        const infoBody = {
          jwt,
          json: parsedJson
        };
        let message = "Called with:\n\n";
        message += JSON.stringify(infoBody, null, 2) + "\n\n";
        message += "Parsed JWT:\n\n";
        message += Buffer.from(body.jwt.split('.')[1], 'base64').toString() + "\n\n";

        const pageSize = 5;   // for demo purposes, but really something like 1000 would be reasonable
        const learnersArray = await fetchLearnerData(jwt, parsedJson.query, learnersApiUrl, pageSize);

        message += `Learners returned, using page size ${pageSize}:\n`;
        message += `  Total pages: ${learnersArray.length}\n`;
        if (learnersArray.length > 0) {
          message += `  Total learners: ${learnersArray.reduce((acc, arr) => acc + arr.length, 0)}\n\n`;
          message += JSON.stringify(learnersArray, null, 2);
        }

        response = {
          statusCode: 200,
          body: message
        }
      } else {
        const json = body.json;
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
      }
    } catch (err) {
      console.log("Error occured:");
      console.log(err.stack);
      response = {
        statusCode: 500,
        body: err.stack
      }
    }

    return response
};

function validateJSON(event) {
  if (!event.body) {
    throw new Error("Missing post body in request")
  }

  const body = queryString.parse(event.body);

  if (body.jwt) {
    // pass back the whole request without any verification
    return body;
  }

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

  body.json = json;

  return body;
}

/**
 * To demonstrate the pagination, this returns a 2d array, each array is one batch of learners returned
 */
async function fetchLearnerData(jwt, query, learnersApiUrl, pageSize) {
  const queryParams = {
    query,
    page_size: pageSize
  };
  const allLearners = [];
  let foundAllLearners = false;

  while (!foundAllLearners) {
    const res = await getLearnerDataWithJwt(learnersApiUrl, queryParams, jwt);
    if (res.json.learners) {
      console.log(`Recieved ${res.json.learners.length} learners`);
      console.log(`  lastHitSortValue: ${res.json.lastHitSortValue}`);

      allLearners.push(res.json.learners);

      if (res.json.learners.length < pageSize && res.json.lastHitSortValue) {
        foundAllLearners = true;
      } else {
        queryParams.search_after = res.json.lastHitSortValue;
      }
    } else {
      throw new Error("Malformed response from the portal: " + JSON.stringify(res));
    }
  }
  return allLearners;
}

async function getLearnerDataWithJwt(learnersApiUrl, queryParams, jwt) {
  try {
    const res = await axios.post(learnersApiUrl, queryParams,
      {
        headers: {
          "Authorization": `Bearer/JWT ${jwt}`
        }
      }
    );
    return res.data;
  } catch (error) {
    if (error.response) {
      // The request was made and the server responded with a status code
      // that falls out of the range of 2xx
      const details = JSON.stringify({
        url: error.config.url,
        method: error.config.method,
        requestData: queryParams,
        requestHeaders: error.config.headers,
        responseStatus: error.response.status,
        responseData: error.response.data
      }, null, 2);
      throw new Error(`Request failed, details: ${details}`);
    } else if (error.request) {
      // The request was made but no response was received
      // `error.request` is an instance of http.ClientRequest in node.js
      const details = JSON.stringify({
        url: error.config.url,
        method: error.config.method,
        requestData: queryParams,
        requestHeaders: error.config.headers,
        clientRequest: error.request
      }, null, 2);
      throw new Error(`No response received, details: ${details}`);
    } else {
      // Something happened in setting up the request that triggered an Error
      throw new Error(`Request setup error ${error.message}
        config: ${JSON.stringify(error.config, null, 2)}`);
    }
  }
}
