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
var NgssHelper = function () {
  var PE = 'Performance Expectations'
  var DCI = 'Disciplinary Core Ideas'
  var PRACTICES = 'Science and Engineering Practices'
  var CONCEPTS = 'Crosscutting Concepts'

  //
  // Four groups in NGSS.
  //      Two are lists PE and DCI (handle statements individually.)
  //      Two are maps (grouped by sub nodes one level below root.)
  //
  this.pe = []
  this.dci = []
  this.practicesGroup = {}
  this.conceptsGroup = {}

  var _this = this

  //
  // Add a statement to the NGSS groupings.
  //
  this.add = function (statement) {
    // console.log("[DEBUG] NGSS Helper adding", statement);
    var descArr = statement.description

    var arrMap = {}
    arrMap[DCI] = this.dci

    var subGroup = {}
    subGroup[PRACTICES] = this.practicesGroup
    subGroup[CONCEPTS] = this.conceptsGroup

    //
    // First check for groupings from practices and concepts. (sub grouped)
    // Then check for DCIs.
    // Finally default to "Performance Expectations" (PE)
    //
    if (descArr.length > 0 && descArr[0]) {
      var group = descArr[0]
      var sub = subGroup[group]
      if (sub) {
        //
        // This is a practice or a crosscutting concept
        //
        // console.log("[DEBUG] NGSS Helper finding map", group, sub);
        if (descArr.length > 1 && descArr[1]) {
          var title = descArr[1]
          if (!sub[title]) {
            sub[title] = []
          }
          var list = sub[title]
          list.push(statement)
        }
      } else {
        //
        // This is a DCI, or a PE.
        //
        // console.log("[DEBUG] NGSS Helper finding array", group, arrMap);
        var arr = this.pe
        if (arrMap[group]) {
          arr = arrMap[group]
        }
        // console.log("[DEBUG] NGSS Helper pushing", statement);
        arr.push(statement)
      }
    }
  }

  //
  // Return a div with NGSS statements grouped for display.
  //
  this.getDiv = function () {
    // console.log("[DEBUG] NGSS Helper getDiv()");

    if (this.pe.length === 0 &&
            this.dci.length === 0 &&
            Object.keys(this.practicesGroup).length === 0 &&
            Object.keys(this.conceptsGroup).length === 0) {
      // console.log("[DEBUG] Nothing to display.");
      return null
    }

    //
    // Create a non-null div for each top level group with applicable items.
    //
    var peDiv = null
    var dciDiv = null

    //
    // Simplest case PE (any statement not matching the other
    // three types.) Display notation and full concat description.
    //
    if (this.pe.length > 0) {
      // console.log("[DEBUG] Displaying PEs", this.pe);

      peDiv = <div>
        <b><i>{PE}</i></b>
        <br />
        {this.pe.map(function (s) {
          var description = s.description
          if (Array.isArray && Array.isArray(description)) {
            var formatted = ''
            for (var i = 0; i < description.length; i++) {
              if (description[i].endsWith(':')) {
                description[i] += ' '
              } else if (!description[i].endsWith('.')) {
                description[i] += '. '
              }
              formatted += description[i]
            }
            description = formatted
          }
          return <>
            <h3>{s.notation}</h3>
            {description}
          </>
        })}
      </div>
    }

    //
    // Most complicated case is DCI in which notation is composed of
    // leaf grade level and parent notation
    //
    if (this.dci.length > 0) {
      // console.log("[DEBUG] Displaying DCIs", this.dci);

      //
      // For each statement display:
      //
      // - Notation ( DCI notation is derived:
      //              leaf grade level + leaf parent notation )
      // - Title  ( leaf parent desc )
      // - Desc   ( leaf desc )
      //
      dciDiv = <div>
        <b><i>{DCI}</i></b>
        <br />
        {this.dci.map(function (s) {
          // console.log("[DEBUG] Displaying DCI", s);
          var arrDesc = s.description
          if (arrDesc.length < 3) { return null }
          var notation = ''
          if (s.parents.length > 0) {
            var parent = s.parents[0]
            var grade = _this.getGradeLevel(s.education_level)
            notation = grade + '-' + parent.statement_notation
          }
          return <>
            <b>{notation}</b> {arrDesc[1]}
            <br />
            {arrDesc[2]}
            <br />
          </>
        })}
      </div>
    }

    //
    // Create grouped divs - grouped by second level node desc.
    // Practices and Crosscutting Concepts are displayed this way.
    //
    var getGroupedDiv = function (groupMap, heading) {
      if (Object.keys(groupMap).length > 0) {
        // console.log("[DEBUG] Displaying group", groupMap);

        //
        // For each statement display:
        //
        // - Title  ( from second level node desc )
        // - Desc   ( desc from all remaining child nodes down
        //              to leaf )
        //
        var groupedDiv = <div>
          <b><i>{heading}</i></b>
          <br />

          {Object.keys(groupMap).map(function (title) {
            var statements = groupMap[title]
            return <>
              <b>{title}</b>
              <br />
              {statements.map(function (s) {
                var arrDesc = s.description
                if (arrDesc.length < 3) { return null }
                var desc = ''
                for (var i = 2; i < arrDesc.length; i++) {
                  desc += arrDesc[i]
                  if (arrDesc[i].endsWith('.')) {
                    desc += ' '
                  }
                }
                return <>{desc}<br /></>
              })}
            </>
          })}
        </div>

        return groupedDiv
      }
    }

    var practicesDiv = getGroupedDiv(this.practicesGroup, PRACTICES)
    var conceptsDiv = getGroupedDiv(this.conceptsGroup, CONCEPTS)

    return (
      <div>
        {peDiv}
        {dciDiv}
        {practicesDiv}
        {conceptsDiv}
      </div>
    )
  }

  //
  // Grade level arrays for DCI notation generation.
  //
  var ES = [ 'K', '1', '2', '3', '4', '5' ]
  var MS = [ '6', '7', '8' ].sort()
  var HS = [ '9', '10', '11', '12' ].sort()

  //
  // Returns a grade level string suitable for composing a
  // notation string for a DCI.
  //
  this.getGradeLevel = function (gradeArray) {
    // some gradeArrays have been null
    if (!gradeArray) {
      return 'UNKNOWN'
    }

    //
    // For single grade level return single grade.
    //
    if (gradeArray.length === 1) {
      return gradeArray[0]
    }

    gradeArray.sort()

    var isMatch = function (arr) {
      if (gradeArray.length === arr.length) {
        var match = true
        for (var i = 0; i < gradeArray.length; i++) {
          if (gradeArray[i] !== arr[i]) {
            match = false
            break
          }
        }
        return match
      }
      return false
    }

    //
    // Check if array "b" is a subset of array "a".
    //
    var isSubset = function (a, b) {
      for (var i = 0; i < b.length; i++) {
        if (a.indexOf(b[i]) < 0) {
          return false
        }
      }
      return true
    }

    if (isMatch(HS)) { return 'HS' }
    if (isMatch(MS)) { return 'MS' }

    if (isSubset(ES, gradeArray)) { return 'ES' }

    //
    // Could not determine grade level.
    //
    return 'UNKNOWN'
  }

  return this
}

/**
 *
 * Get a helper for a standards type.
 *
 * @param standardType - The standard type. E.g. "NGSS"
 *
 */
var getStandardsHelper = function (standardType) {
  if (standardType === 'NGSS') { return new NgssHelper() }
}

export default {
  getStandardsHelper: getStandardsHelper,
  NgssHelper: NgssHelper
}
