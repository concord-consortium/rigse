import React from "react";
import Component from "../helpers/component";
import StandardsHelpers from "../helpers/standards-helpers";

const StemFinderResultStandards = Component({

  shouldComponentUpdate () {
    return false;
  },

  render () {
    const { standardStatements } = this.props;
    const helpers: any = {};
    const unhelped = [];

    helpers.NGSS = StandardsHelpers.getStandardsHelper("NGSS");

    for (let i = 0; i < standardStatements.length; i++) {
      const statement = standardStatements[i];
      const helper = helpers[statement.type];

      if (helper) {
        helper.add(statement);
      } else {
        unhelped.push(statement);
      }
    }

    const unhelpedStandards = unhelped.map(function (statement, idx) {
      let description = statement.description;
      if (Array.isArray(description)) {
        let formatted = "";
        for (let i = 0; i < description.length; i++) {
          if (description[i].endsWith(":")) {
            description[i] += " ";
          } else if (!description[i].endsWith(".")) {
            description[i] += ". ";
          }
          formatted += description[i];
        }
        description = formatted;
      }
      return (
        <div key={idx}>
          <h3>{ statement.notation }</h3>
          { description }
        </div>
      );
    });

    return (
      <>
        { helpers.NGSS.getDiv() }
        { unhelpedStandards }
      </>
    );
  }
});

export default StemFinderResultStandards;
