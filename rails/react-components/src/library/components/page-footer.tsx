import React from "react";
import Component from "../helpers/component";

const PageFooter = Component({

  getInitialState () {
    return {
      loggedIn: Portal.currentUser.isLoggedIn,
      opacity: 0,
      userId: 0
    };
  },

  render () {
    const year = (new Date()).getFullYear();
    return (
      <div id="footer">
        <div className="footer-inner">
          <p>
            Copyright <span className="copyright">©</span> { year } <a href="https://concord.org" id="footer_cc_link">Concord Consortium</a>. All rights reserved.
            <br />
            <a href="https://concord.org/privacy-policy" id="privacy-policy-link" target="_blank" rel="noopener noreferrer">Privacy Policy</a> · Questions/Feedback: <a href="mailto:help@concord.org?subject=STEM%20Resource%20Finder%20question">Send us an email</a>
            <br />
            Version: unknown
          </p>
        </div>
      </div>
    );
  }
});

export default PageFooter;
