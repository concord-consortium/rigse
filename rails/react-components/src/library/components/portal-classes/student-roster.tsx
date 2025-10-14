import React from "react";

import RegisterStudentModal from "./register-student-modal";
import StudentRosterRow from "./student-roster-row";
import ModalDialog from "../shared/modal-dialog";
import api from "../../helpers/api";
import TriStateCheckbox from "../common/tri-state-checkbox";
import { ManageStudentsForm } from "./manage-students-form";

import css from "./student-roster.scss";
import modalDialogCSS from "../shared/modal-dialog.scss";

const apiBasePath = "/api/v1/students";
const apiCall = api({
  remove: { url: `${apiBasePath}/remove_from_class` },
  add: { url: `${apiBasePath}/add_to_class` },
  register: { url: `${apiBasePath}/register` }
});

const REGISTERED_STUDENT_HASH_MARKER = "#registered_student";

export default class StudentRoster extends React.Component<any, any> {
  constructor (props: any) {
    super(props);

    this.state = {
      showRegisterStudentModal: false,
      showRegisterAnotherStudentModal: false,
      showManageStudentsModal: false,
      studentCheckboxes: {}
    };

    this.handleRemoveStudent = this.handleRemoveStudent.bind(this);
    this.handleChangePassword = this.handleChangePassword.bind(this);
    this.handleAddStudent = this.handleAddStudent.bind(this);
    this.handleToggleRegisterStudentModal = this.handleToggleRegisterStudentModal.bind(this);
    this.handleRegisterStudent = this.handleRegisterStudent.bind(this);
    this.handleToggleRegisterAnotherModal = this.handleToggleRegisterAnotherModal.bind(this);
    this.handleRegisterAnotherStudent = this.handleRegisterAnotherStudent.bind(this);
    this.handleStudentCheckboxChange = this.handleStudentCheckboxChange.bind(this);
    this.handleAllStudentCheckboxChange = this.handleAllStudentCheckboxChange.bind(this);
  }

  // eslint-disable-next-line camelcase
  UNSAFE_componentWillMount () {
    if (window.location.hash === REGISTERED_STUDENT_HASH_MARKER) {
      this.setState({ showRegisterAnotherStudentModal: true });
      window.location.hash = "";
    }
  }

  handleRemoveStudent (student: any) {
    const { clazz } = this.props;
    if (window.confirm(`This will remove the student: '${student.name}' from the class: ${clazz.name}.\n\nAre you sure you want to do this?`)) {
      apiCall("remove", {
        data: {
          student_clazz_id: student.student_clazz_id
        },
        errorMessage: "Unable to remove student!",
        onSuccess: () => window.location.reload()
      });
    }
  }

  handleChangePassword (student: any) {
    if (student.is_oauth_user) {
      window.alert(`This student is authenticated as a ${student.oauth_provider} user. You cannot change this password.`);
    } else {
      window.location.assign(`/users/${student.user_id}/reset_password`);
    }
  }

  handleStudentCheckboxChange (student: any, checked: boolean) {
    this.setState((prevState: any) => ({
      studentCheckboxes: {
        ...prevState.studentCheckboxes,
        [student.user_id]: checked
      }
    }));
  }

  handleAllStudentCheckboxChange (checked: boolean) {
    if (checked) {
      const studentCheckboxes: Record<string, boolean> = {};
      this.props.students.forEach((s: any) => {
        studentCheckboxes[s.user_id] = true;
      });
      this.setState({ studentCheckboxes });
    } else {
      this.setState({ studentCheckboxes: {} });
    }
  }

  handleAddStudent (otherStudent: any) {
    apiCall("add", {
      data: {
        clazz_id: this.props.clazz.id,
        student_id: otherStudent.id
      },
      errorMessage: "Unable to add student!",
      onSuccess: () => window.location.reload()
    });
  }

  handleRegisterStudent (fields: any) {
    const { firstName, lastName, password, passwordConfirmation } = fields;
    apiCall("register", {
      data: {
        clazz_id: this.props.clazz.id,
        user: {
          first_name: firstName,
          last_name: lastName,
          password,
          password_confirmation: passwordConfirmation
        }
      },
      errorMessage: "Unable to register student!",
      onSuccess: () => {
        // trigger the "register another student?" modal after reload
        window.location.hash = REGISTERED_STUDENT_HASH_MARKER;
        window.location.reload();
      }
    });
  }

  handleToggleRegisterStudentModal () {
    this.setState((prevState: any) => ({ showRegisterStudentModal: !prevState.showRegisterStudentModal }));
  }

  handleToggleRegisterAnotherModal () {
    this.setState((prevState: any) => ({ showRegisterAnotherStudentModal: !prevState.showRegisterAnotherStudentModal }));
  }

  handleRegisterAnotherStudent () {
    this.setState({
      showRegisterStudentModal: false,
      showRegisterAnotherStudentModal: true
    });
  }

  renderRegisterAnotherModal () {
    return (
      <ModalDialog title="Success! The student was registered and added to the class" borderColor="orange">
        <div className={modalDialogCSS.registerAnotherStudentDialogContent}>
          <p>
            Do you wish to register and add another student?
          </p>
          <p className={modalDialogCSS.buttons}>
            <button onClick={this.handleRegisterAnotherStudent}>Add Another Student</button>
            <button onClick={this.handleToggleRegisterAnotherModal}>Cancel</button>
          </p>
        </div>
      </ModalDialog>
    );
  }

  renderManageStudentsModal () {
    const { clazz, students } = this.props;
    const { studentCheckboxes } = this.state;
    const selectedStudents = students.filter((s: any) => studentCheckboxes[s.user_id]);

    return (
      <ModalDialog borderColor="orange">
        <ManageStudentsForm
          students={selectedStudents}
          totalStudents={students.length}
          className={clazz.name}
          teacherIds={ clazz.teacherIds }
          onFormClose={() => this.setState({ showManageStudentsModal: false })}
        />
      </ModalDialog>
    );
  }

  renderStudents (canEdit: any) {
    const { students, canManageStudents } = this.props;
    const { studentCheckboxes } = this.state;

    if (students.length === 0) {
      return <div>No students registered for this class yet.</div>;
    }

    const allStudentsChecked = students.every((s: any) => studentCheckboxes[s.user_id]);
    const noStudentsChecked = students.every((s: any) => !studentCheckboxes[s.user_id]);
    const someStudentsChecked = !allStudentsChecked && !noStudentsChecked;

    return (
      <table className={css.table}>
        <tbody>
          <tr>
            { canManageStudents &&
              <th>
               {/*
                  Using allStudentsChecked for the checked prop means that when only some students are
                  checked, clicking on the checkbox will toggle it to checked.
                  handleAllStudentsCheckboxChange will then select all students.
                  Note: In the assignments page there are similar checkboxes but their behavior is not
                  deterministic. Sometimes clicking them will check all students and sometimes clicking them
                  will uncheck all students.
                */}
                <TriStateCheckbox
                  checked={allStudentsChecked}
                  partiallyChecked={someStudentsChecked}
                  onChange={this.handleAllStudentCheckboxChange} />
              </th> }
            <th>Name</th>
            <th>Username</th>
            <th>Last Login</th>
            <th>Assignments Started</th>
            { canEdit ? <th className="hide_in_print" /> : undefined }
          </tr>
          { students.map((student: any) => <StudentRosterRow
            key={student.student_id}
            student={student}
            canEdit={canEdit}
            canManageStudents={canManageStudents}
            studentCheckboxChecked={!!studentCheckboxes[student.user_id]}
            onStudentCheckboxChange={this.handleStudentCheckboxChange}
            onRemoveStudent={this.handleRemoveStudent}
            onChangePassword={this.handleChangePassword}
          />) }
        </tbody>
      </table>
    );
  }

  render () {
    const {
      showRegisterStudentModal,
      showRegisterAnotherStudentModal,
      showManageStudentsModal,
      studentCheckboxes
    } = this.state;
    const {
      canEdit,
      canManageStudents,
      students
     } = this.props;

    const someStudentsSelected = students.some((s: any) => studentCheckboxes[s.user_id]);
    return (
      <>
        {/* { canEdit ? <StudentRosterHeader otherStudents={otherStudents} onAddStudent={this.handleAddStudent} onRegisterStudent={this.handleToggleRegisterStudentModal} /> : undefined } */}
        { canManageStudents &&
          <div className={css.newHeader}>
            <button
              onClick={() => this.setState({ showManageStudentsModal: true })}
              disabled={!someStudentsSelected}
            >
              Manage Students
            </button>
          </div>
        }
        { this.renderStudents(canEdit) }
        { showRegisterStudentModal && <RegisterStudentModal onSubmit={this.handleRegisterStudent} onCancel={this.handleToggleRegisterStudentModal} /> }
        { showRegisterAnotherStudentModal && this.renderRegisterAnotherModal() }
        { showManageStudentsModal && this.renderManageStudentsModal() }
      </>
    );
  }
}
