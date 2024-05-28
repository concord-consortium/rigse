import React from "react";
import PortalClassInformation from "./information";
import TeacherList from "./teacher-list";
import FormErrors from "../../helpers/form-errors";
import railsFormField from "../../helpers/rails-form-field";

export default class ClassSetupForm extends React.Component<any, any> {
  constructor (props: any) {
    super(props);

    this.state = {
      currentTeachers: this.props.teachers.current
    };

    this.handleSetCurrentTeachers = this.handleSetCurrentTeachers.bind(this);
  }

  handleSetCurrentTeachers (currentTeachers: any) {
    this.setState({ currentTeachers });
  }

  renderLabelCell (label: any, field: any) {
    return (
      <td className="title">
        <label className="right" htmlFor={field.id} style={{ whiteSpace: "nowrap" }}>{ label }:</label>
      </td>
    );
  }

  render () {
    const { currentTeachers } = this.state;
    const { portalClass, portalClassTeacher, schools, portalClassGrades, enableGradeLevels, activeGrades, cancelLink, errors, teachers } = this.props;
    const creating = !portalClass.id;
    const updating = !creating;
    const field = railsFormField("portal_clazz");
    const nameField = field("name");
    const teachersField = field("teachers");
    const descriptionField = field("description");
    const classWordField = field("class_word");
    const schoolField = field("school");
    const gradeLevelsField = field("grade_levels");
    const currentTeachersField = field("current_teachers");

    const gradeLevelCols = 4;
    const gradeLevelWidth = 95.0 / gradeLevelCols;

    const gradeLevelRows: any = [];
    activeGrades.forEach(function (activeGrade: any, index: any) {
      const row = Math.floor(index / gradeLevelCols);
      gradeLevelRows[row] = (gradeLevelRows[row] || []);
      gradeLevelRows[row].push(activeGrade);
    });

    return (
      <>
        <div className="content">
          <FormErrors errors={errors} />
        </div>
        <div className="right">
          <h1>Class Setup Information</h1>

          { updating ? <PortalClassInformation portalClass={portalClass} portalClassTeacher={portalClassTeacher} /> : undefined }

          <table className="classsetupform">
            <tbody>
              <tr>
                { this.renderLabelCell("Class Name", nameField) }
                <td>
                  <input id={nameField.id} name={nameField.name} size={30} type="text" defaultValue={portalClass.name} />
                </td>
              </tr>
              {
                updating ?
                  <tr>
                    { this.renderLabelCell("Teachers", teachersField) }
                    <td className="left">
                      <TeacherList portalClassTeacher={portalClassTeacher} teachers={teachers} setCurrentTeachers={this.handleSetCurrentTeachers} />
                    </td>
                  </tr>
                  : undefined
              }
              <tr>
                { this.renderLabelCell("Description", descriptionField) }
                <td>
                  <textarea className="mceNoEditor" id={descriptionField.id} name={descriptionField.name} rows={5} cols={50} defaultValue={portalClass.description} />
                </td>
              </tr>
              <tr>
                { this.renderLabelCell("Class Word", classWordField) }
                <td>
                  <input id={classWordField.id} name={classWordField.name} type="text" defaultValue={portalClass.class_word} />
                </td>
              </tr>
              {
                creating ?
                  <tr>
                    { this.renderLabelCell("School", schoolField) }
                    <td>
                      <select id={schoolField.id} name={schoolField.name} >
                        { schools.map(function (school: any) {
                          return <option key={school.id} value={school.id} defaultChecked={portalClass.school === school.id}>{ school.name }</option>;
                        }) }
                      </select>
                    </td>
                  </tr>
                  : undefined
              }
              {
                enableGradeLevels ?
                  <tr>
                    { this.renderLabelCell("Grade Levels", gradeLevelsField) }
                    <td>
                      <table style={{ width: "100%" }}>
                        <tbody>
                          { gradeLevelRows.map(function (row: any, rowIndex: number) {
                            return (
                              <tr key={rowIndex}>
                                { row.map(function (grade: any) {
                                  const name = `${gradeLevelsField.name}[${grade}]`;
                                  const checked = portalClassGrades.indexOf(grade) !== -1;
                                  return (
                                    <td key={grade} style={{ textAlign: "left", whiteSpace: "nowrap", width: `${gradeLevelWidth}%` }}>
                                      <input type="checkbox" id={name} name={name} value="1" defaultChecked={checked} /> <label htmlFor={name}>{ grade }</label>
                                    </td>
                                  );
                                }) }
                              </tr>
                            );
                          }) }
                        </tbody>
                      </table>
                    </td>
                  </tr>
                  : undefined
              }
            </tbody>
          </table>
          <hr className="ht-thick" />
          <div className="form-submit">
            <a href={cancelLink}>Cancel</a>
            <span className="create_button">
              <input type="submit" className="pie" value="Save Changes" />
            </span>
          </div>
        </div>
        <input type="hidden" name="teacher_id" value={portalClass.teacher_id} />
        { portalClass.id ? <input type="hidden" name="id" value={portalClass.id} /> : undefined }
        { updating ? <input type="hidden" name={currentTeachersField.name} value={currentTeachers.map((t: any) => t.id).join(",")} /> : undefined }
      </>
    );
  }
}
