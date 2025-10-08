import React from "react";
import css from "./style.scss";

export default class ResearcherClassesTable extends React.Component<any, any> {
  static defaultProps = {
    classes: []
  };

  constructor (props: any) {
    super(props);
    this.state = {
      sortedClasses: props.classes,
      // Default sort by id in descending order - this will show the most recent classes first
      sortBy: "id",
      sortDirection: "desc",
      showSchoolName: false
    };
  }

  componentDidMount () {
    this.sortClasses();
  }

  componentDidUpdate (prevProps: any) {
    if (this.props.classes !== prevProps.classes) {
      this.sortClasses(this.props.classes);
    }
  }

  sortClasses (classesToSort = this.state.sortedClasses) {
    const fieldName = this.state.sortBy;
    const direction = this.state.sortDirection;
    this.setState({
      sortedClasses: classesToSort.slice().sort((a: any, b: any) => {
        // Using localeCompare for a more natural sort order
        const comparison = a[fieldName].toString().localeCompare(b[fieldName].toString(), "en", { sensitivity: "base" });
        return direction === "asc" ? comparison : -comparison;
      })
    });
  }

  fieldSortIcon (fieldName: any) {
    if (this.state.sortBy === fieldName) {
      return this.state.sortDirection === "asc" ? css.asc : css.desc;
    }
    return "";
  }

  handleHeaderClick (fieldName: string) {
    this.setState((oldState: any) => ({
      sortBy: fieldName,
      sortDirection: oldState.sortBy === fieldName && oldState.sortDirection === "asc" ? "desc" : "asc"
    }), () => this.sortClasses());
  }

  handleShowSchoolNameChange (e: any) {
    this.setState({ showSchoolName: e.target.checked });
  }

  renderHeader (label: any, fieldName: any) {
    return (
      <th onClick={this.handleHeaderClick.bind(this, fieldName)}>
        <span className={css.header}>
          { label } <span className={`${css.sortIcon} ${this.fieldSortIcon(fieldName)} icon-sort`} />
        </span>
      </th>
    );
  }

  render () {
    const { sortedClasses, showSchoolName } = this.state;
    if (sortedClasses.length === 0) {
      return null;
    }
    return (
      <div className={css.researcherClassesTable}>
        <hr />
        <div className={css.top}>
          <div className={css.resultsLabel}>Results</div>
          <span>
            <input type="checkbox" checked={showSchoolName} onChange={this.handleShowSchoolNameChange.bind(this)} /> Show School Name
          </span>
        </div>

        <table>
          <thead>
            <tr>
              { this.renderHeader("Cohort", "cohort_names") }
              { this.renderHeader("Teacher", "teacher_names") }
              { this.renderHeader("Class", "name") }
              { showSchoolName && this.renderHeader("School", "school_name") }
              <th />
            </tr>
          </thead>
          <tbody>
            {
              sortedClasses.map((c: any, i: any) => (
                <tr key={i}>
                  <td>{ c.cohort_names }</td>
                  <td>{ c.teacher_names }</td>
                  <td>{ c.name }</td>
                  { showSchoolName && <td>{ c.school_name }</td> }
                  <td className={css.linkCell}>
                    <a href={c.materials_url} target="_blank" rel="noreferrer">View Assignments</a>
                    { c.roster_url && 
                      <><br /><a href={c.roster_url} target="_blank" rel="noreferrer">View Roster</a></>
                    }
                  </td>
                </tr>
              ))
            }
          </tbody>
        </table>
      </div>
    );
  }
}
