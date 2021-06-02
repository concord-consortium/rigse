'use strict';

const app = require('../../app.js');
const chai = require('chai');
const expect = chai.expect;
// signature generated using the HMAC secret "test-key"
var event = {
    body: "allowDebug=1&json=%7B%22type%22%3A%22users%22%2C%22version%22%3A%221.0%22%2C%22domain%22%3A%22learn.staging.concord.org%22%2C%22users%22%3A%5B%7B%22id%22%3A66%2C%22first_name%22%3A%22Sam%22%2C%22last_name%22%3A%22Fentress%22%2C%22username%22%3A%22sfentress%22%7D%5D%2C%22runnables%22%3A%5B%5D%2C%22start_date%22%3Anull%2C%22end_date%22%3Anull%7D&signature=88100449ea96962c88beaf2a54e19e280284e35dd93bb365b4401e8e00eec6ba"
};

describe('Tests index', function () {
    it('verifies successful response', async () => {
        const result = await app.lambdaHandler(event)

        expect(result).to.be.an('object');
        expect(result.statusCode).to.equal(200);
        expect(result.body).to.be.an('string');

        expect(result.body).to.match(/id,first_name,last_name,username/);
        expect(result.body).to.match(/66,Sam,Fentress,sfentress/);
    });
});
