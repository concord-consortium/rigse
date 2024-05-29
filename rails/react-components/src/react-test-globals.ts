// this is loaded by react_helper.js.coffee during tests and used to create helpers

import ReactDOMServer from "react-dom/server";
import ReactTestUtils from "react-dom/test-utils";

(window as any).ReactDOMServer = ReactDOMServer;
(window as any).ReactTestUtils = ReactTestUtils;
