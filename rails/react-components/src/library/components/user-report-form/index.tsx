import React from "react";
import Select from "react-select";
import jQuery from "jquery";
import ExternalReportButton from "../common/external-report-button";
import { formatInputDateToMMDDYYYY } from "../../helpers/format-date";

import css from "./style.scss";

const title = (str: any) => (str.charAt(0).toUpperCase() + str.slice(1)).replace(/_/g, " ");

const queryCache: any = {};

export default class UserReportForm extends React.Component<any, any> {
  static defaultProps: { externalReports: never[] };

  constructor (props: any) {
    super(props);
    this.state = {
      // the current values of the filters
      teachers: [],
      cohorts: [],
      runnables: [],
      start_date: "",
      end_date: "",
      // all possible values for each pulldown
      filterables: {
        teachers: [],
        cohorts: [],
        runnables: []
      },
      // waiting for results
      waitingFor_teachers: false,
      waitingFor_cohorts: false,
      waitingFor_runnables: false,
      totals: {},
      // checkbox options
      removeCCTeachers: false,
      externalReportButtonDisabled: true,
      queryParams: {}
    };
  }

  UNSAFE_componentWillMount () {
    this.getTotals();
  }

  getTotals () {
    jQuery.ajax({
      url: "/api/v1/report_users",
      type: "GET",
      data: { totals: true, remove_cc_teachers: this.state.removeCCTeachers }
    }).then(data => {
      if (data.error) {
        window.alert(data.error);
      }
      if (data.totals) {
        this.setState({ totals: data.totals });
      }
    });
  }

  query (_params: any, _fieldName?: any, searchString?: any) {
    if (_fieldName) {
      this.setState({ [`waitingFor_${_fieldName}`]: true });
    }
    const params = jQuery.extend({}, _params); // clone
    if (_fieldName) {
      // we remove the value of each field from the filter query for that
      // dropdown, as we want to know all possible values for that dropdown
      // given only the other filters
      delete params[_fieldName];
    }
    if (searchString) {
      params[_fieldName] = searchString;
    }

    const cacheKey = JSON.stringify(params);

    const handleResponse = (fieldName => {
      return (data: any) => {
        const newState: any = { filterables: this.state.filterables };

        queryCache[cacheKey] = data;

        const hits = data.hits?.[fieldName] ? data.hits[fieldName] : [];
        if (searchString) {
          // merge results and remove dups
          const merged = (newState.filterables[fieldName] || []).concat(hits);
          newState.filterables[fieldName] = merged.filter((str: any, i: any) => merged.indexOf(str) === i);
        } else {
          newState.filterables[fieldName] = hits;
        }

        newState.filterables[fieldName].sort((a: any, b: any) => a.label.localeCompare(b.label));

        newState[`waitingFor_${_fieldName}`] = false;
        this.setState(newState);
        return data;
      };
    })(_fieldName);

    if ((queryCache[cacheKey] != null ? queryCache[cacheKey].then : undefined)) { // already made a Promise that is still pending
      queryCache[cacheKey].then(handleResponse); // chain a new Then
    } else if (queryCache[cacheKey]) { // have data that has already returned
      handleResponse(queryCache[cacheKey]); // use it directly
    } else {
      queryCache[cacheKey] = jQuery.ajax({ // make req and add new Promise to cache
        url: "/api/v1/report_users",
        type: "GET",
        data: params
      }).then(handleResponse);
    }
  }

  getQueryParams () {
    const params: any = { remove_cc_teachers: this.state.removeCCTeachers };
    for (const filter of ["teachers", "cohorts", "runnables"]) {
      if ((this.state[filter] != null ? this.state[filter].length : undefined) > 0) {
        params[filter] = this.state[filter].map((v: any) => v.value).sort().join(",");
      }
    }
    for (const filter of ["start_date", "end_date"]) {
      if ((this.state[filter] != null ? this.state[filter].length : undefined) > 0) {
        params[filter] = formatInputDateToMMDDYYYY(this.state[filter]);
      }
    }
    return params;
  }

  updateQueryParams () {
    const queryParams = this.getQueryParams();
    // <= 1 is used because the params always has remove_cc_teachers defined
    const externalReportButtonDisabled = Object.keys(queryParams).length <= 1;
    this.setState({ queryParams, externalReportButtonDisabled });
  }

  updateFilters () {
    const params = this.getQueryParams();
    this.query(params);
    this.query(params, "teachers");
    this.query(params, "cohorts");
    this.query(params, "runnables");
  }

  renderInput (name: any, titleOverride?: any) {
    if (!this.state.filterables[name]) { return; }

    const hits = this.state.filterables[name];

    const isLoading = this.state[`waitingFor_${name}`];
    const placeholder = !isLoading ? (hits.length === 0 ? "Search..." : "Select or search...") : "Loading ...";

    const options = hits.map((hit: any) => {
      return { value: hit.id, label: hit.label };
    });

    const handleSelectInputChange = (value: any) => {
      if (value.length === 4) {
        const params = this.getQueryParams();
        this.query(params, name, value);
      }
    };

    const handleSelectChange = (value: any) => {
      this.setState({ [name]: value }, () => {
        this.updateFilters();
        this.updateQueryParams();
      });
    };

    const handleLoadAll = (e: any) => {
      e.preventDefault();
      this.query({ load_all: name, remove_cc_teachers: this.state.removeCCTeachers }, name);
    };

    const titleCounts = Object.prototype.hasOwnProperty.call(this.state.totals, name) ? ` (${hits.length} of ${this.state.totals[name]})` : "";
    let loadAllLink;
    if ((this.state.totals[name] > 0) && (hits.length !== this.state.totals[name])) {
      loadAllLink = <a href="#" onClick={handleLoadAll} style={{ marginLeft: 10 }}>load all</a>;
    }

    return (
      <div style={{ marginTop: "6px" }}>
        <span>{ `${titleOverride || title(name)}${titleCounts}` }{ loadAllLink }</span>
        <Select
          name={name}
          options={options}
          isMulti
          placeholder={placeholder}
          isLoading={isLoading}
          value={this.state[name]}
          onInputChange={handleSelectInputChange}
          onChange={handleSelectChange}
        />
      </div>
    );
  }

  renderDatePicker (name: "start_date" | "end_date") {
    const label = name === "start_date" ? "Earliest date" : "Latest date";

    const handleChange = (event: any) => {
      const { value } = event.target;

      this.setState({ [name]: value || "" }, () => {
        this.updateQueryParams();
      });
    };

    return (
      <div style={{ marginTop: "6px" }}>
        <div>{ label }</div>
        <input
          type="date"
          name={name}
          value={this.state[name]}
          onChange={handleChange}
        />
      </div>
    );
  }

  renderForm () {
    const { externalReports, portalToken } = this.props;
    const { queryParams, externalReportButtonDisabled } = this.state;
    const queryUrl = Portal.API_V1.EXTERNAL_RESEARCHER_REPORT_USER_QUERY;

    const handleRemoveCCTeachers = (e: any) => {
      this.setState({ removeCCTeachers: e.target.checked }, () => {
        this.getTotals();
        this.updateFilters();
      });
    };

    externalReports.sort((a: any, b: any) => a.label.localeCompare(b.label));
    const adminOnlyExternalReports = externalReports.filter((r: any) => r.name.indexOf("[DEV]") !== -1);
    const nonAdminExternalReports = externalReports.filter((r: any) => adminOnlyExternalReports.indexOf(r) === -1);

    const renderExternalReports = (reports: any) => {
      return reports.map((lr: any) => <ExternalReportButton key={lr.url + lr.label} label={lr.label} reportUrl={lr.url} queryUrl={queryUrl} isDisabled={externalReportButtonDisabled} queryParams={queryParams} portalToken={portalToken} />
      );
    };

    return (
      <form method="get" style={{ minHeight: 700 }}>
        { this.renderInput("teachers") }
        <div style={{ marginTop: "6px" }}>
          <input type="checkbox" checked={this.state.removeCCTeachers} onChange={handleRemoveCCTeachers} /> Remove Concord Consortium Teachers? *
        </div>
        { this.renderInput("cohorts") }
        { this.renderInput("runnables", "Resources") }

        { this.renderDatePicker("start_date") }
        { this.renderDatePicker("end_date") }

        <div style={{ marginTop: "12px" }}>
          { renderExternalReports(nonAdminExternalReports) }
        </div>
        { Portal.currentUser.isAdmin && adminOnlyExternalReports.length > 0 && (
          <>
            <div style={{ marginTop: "12px" }}>
              <strong>For Developers Only:</strong>
            </div>
            <div>
              { renderExternalReports(adminOnlyExternalReports) }
            </div>
          </>
        ) }

        <div style={{ marginTop: "24px" }}>
          * Concord Consortium Teachers belong to schools named "Concord Consortium".
        </div>
        <div style={{ marginTop: "24px" }}>
          Need help?  Read the <a target="_blank" href="https://docs.google.com/document/d/1jNKjSworR_1ARdSPT8vq6PElKqZ-7zw8BFanZiVcxPs/edit" rel="noreferrer">Researcher Reports &amp; Logs User Guide</a>.
        </div>
      </form>
    );
  }

  render () {
    return (
      <div className={css.userReportForm}>
        { this.renderForm() }
        { /* Spacer element is added so there's some space for the date picker element. Portal footer doesn't
            work too well with this form otherwise. */ }
        <div className={css.spacerForDayPicker} />
      </div>
    );
  }
}

UserReportForm.defaultProps = {
  externalReports: []
};
