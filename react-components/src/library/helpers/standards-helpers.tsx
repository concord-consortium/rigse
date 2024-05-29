import React from "react";
/**
 *
 * Helpers for displaying standards statements.
 *
 */

/**
 *
 * Helper to Display NGSS standards statements.
 *
 */
const NgssHelper = function () {
  const PE = "Performance Expectations";
  const DCI = "Disciplinary Core Ideas";
  const PRACTICES = "Science and Engineering Practices";
  const CONCEPTS = "Crosscutting Concepts";

  //
  // Four groups in NGSS.
  //      Two are lists PE and DCI (handle statements individually.)
  //      Two are maps (grouped by sub nodes one level below root.)
  //
  this.pe = [];
  this.dci = [];
  this.practicesGroup = {};
  this.conceptsGroup = {};

  //
  // Add a statement to the NGSS groupings.
  //
  this.add = function (statement: any) {
    const descArr = statement.description;

    const arrMap: any = {};
    arrMap[DCI] = this.dci;

    const subGroup: any = {};
    subGroup[PRACTICES] = this.practicesGroup;
    subGroup[CONCEPTS] = this.conceptsGroup;

    //
    // First check for groupings from practices and concepts. (sub grouped)
    // Then check for DCIs.
    // Finally default to "Performance Expectations" (PE)
    //
    if (descArr.length > 0 && descArr[0]) {
      const group = descArr[0];
      const sub = subGroup[group];
      if (sub) {
        //
        // This is a practice or a crosscutting concept
        //
        if (descArr.length > 1 && descArr[1]) {
          const title = descArr[1];
          if (!sub[title]) {
            sub[title] = [];
          }
          const list = sub[title];
          list.push(statement);
        }
      } else {
        //
        // This is a DCI, or a PE.
        //
        let arr = this.pe;
        if (arrMap[group]) {
          arr = arrMap[group];
        }
        arr.push(statement);
      }
    }
  };

  //
  // Return a div with NGSS statements grouped for display.
  //
  this.getDiv = function () {
    if (this.pe.length === 0 &&
        this.dci.length === 0 &&
        Object.keys(this.practicesGroup).length === 0 &&
        Object.keys(this.conceptsGroup).length === 0) {
      return null;
    }

    //
    // Create a non-null div for each top level group with applicable items.
    //
    let peDiv = null;
    let dciDiv = null;

    //
    // Simplest case PE (any statement not matching the other
    // three types.) Display notation and full concat description.
    //
    if (this.pe.length > 0) {
      peDiv = (
        <div className="standards-ngss-pe">
          <h4>{ PE }</h4>
          { this.pe.map(function (s: any) {
            let description = s.description;
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
              <>
                <h5>{ s.notation }</h5>
                <p>{ description }</p>
              </>
            );
          }) }
        </div>
      );
    }

    //
    // Most complicated case is DCI in which notation is composed of
    // leaf grade level and parent notation
    //
    if (this.dci.length > 0) {
      //
      // For each statement display:
      //
      // - Notation ( DCI notation is derived:
      //              leaf grade level + leaf parent notation )
      // - Title  ( leaf parent desc )
      // - Desc   ( leaf desc )
      //
      dciDiv = (
        <div className="standards-ngss-dci">
          <h4>{ DCI }</h4>
          { this.dci.map((s: any) => {
            const arrDesc = s.description;
            if (arrDesc.length < 3) { return null; }
            let notation = "";
            if (s.parents.length > 0) {
              const parent = s.parents[0];
              const grade = this.getGradeLevel(s.education_level);
              notation = grade + "-" + parent.statement_notation;
            }
            return (
              <>
                <strong>{ notation }</strong> { arrDesc[1] }
                <p>{ arrDesc[2] }</p>
              </>
            );
          }) }
        </div>
      );
    }

    //
    // Create grouped divs - grouped by second level node desc.
    // Practices and Crosscutting Concepts are displayed this way.
    //
    const getGroupedDiv = function (groupMap: any, heading: any) {
      if (Object.keys(groupMap).length > 0) {
        //
        // For each statement display:
        //
        // - Title  ( from second level node desc )
        // - Desc   ( desc from all remaining child nodes down
        //              to leaf )
        //
        const groupedDiv = (
          <div>
            <h4>{ heading }</h4>
            { Object.keys(groupMap).map(function (title) {
              const statements = groupMap[title];
              return (
                <>
                  <strong>{ title }</strong>
                  { statements.map(function (s: any, idx: number) {
                    const arrDesc = s.description;
                    if (arrDesc.length < 3) { return null; }
                    let desc = "";
                    for (let i = 2; i < arrDesc.length; i++) {
                      desc += arrDesc[i];
                      if (arrDesc[i].endsWith(".")) {
                        desc += " ";
                      }
                    }
                    return <p key={idx}>{ desc }</p>;
                  }) }
                </>
              );
            }) }
          </div>
        );

        return groupedDiv;
      }
    };

    const practicesDiv = getGroupedDiv(this.practicesGroup, PRACTICES);
    const conceptsDiv = getGroupedDiv(this.conceptsGroup, CONCEPTS);

    return (
      <div>
        { peDiv }
        { dciDiv }
        { practicesDiv }
        { conceptsDiv }
      </div>
    );
  };

  //
  // Grade level arrays for DCI notation generation.
  //
  const ES = ["K", "1", "2", "3", "4", "5"];
  const MS = ["6", "7", "8"].sort();
  const HS = ["9", "10", "11", "12"].sort();

  //
  // Returns a grade level string suitable for composing a
  // notation string for a DCI.
  //
  this.getGradeLevel = function (gradeArray: any) {
    // some gradeArrays have been null
    if (!gradeArray) {
      return "UNKNOWN";
    }

    //
    // For single grade level return single grade.
    //
    if (gradeArray.length === 1) {
      return gradeArray[0];
    }

    gradeArray.sort();

    const isMatch = function (arr: any) {
      if (gradeArray.length === arr.length) {
        let match = true;
        for (let i = 0; i < gradeArray.length; i++) {
          if (gradeArray[i] !== arr[i]) {
            match = false;
            break;
          }
        }
        return match;
      }
      return false;
    };

    //
    // Check if array "b" is a subset of array "a".
    //
    const isSubset = function (a: any, b: any) {
      for (let i = 0; i < b.length; i++) {
        if (a.indexOf(b[i]) < 0) {
          return false;
        }
      }
      return true;
    };

    if (isMatch(HS)) { return "HS"; }
    if (isMatch(MS)) { return "MS"; }

    if (isSubset(ES, gradeArray)) { return "ES"; }

    //
    // Could not determine grade level.
    //
    return "UNKNOWN";
  };

  return this;
};

/**
 *
 * Get a helper for a standards type.
 *
 * @param standardType - The standard type. E.g. "NGSS"
 *
 */
const getStandardsHelper = function (standardType: any) {
  if (standardType === "NGSS") {
    return new (NgssHelper as any)();
  }
};

export default {
  getStandardsHelper,
  NgssHelper
};
