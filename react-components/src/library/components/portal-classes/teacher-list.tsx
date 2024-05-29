import React from "react";
import DeleteIcon from "../icons/delete-icon";

export default class TeacherList extends React.Component<any, any> {
  selectRef: any;
  constructor (props: any) {
    super(props);
    const { current, unassigned } = this.props.teachers;
    this.state = {
      currentTeachers: current.slice(),
      unassignedTeachers: unassigned.slice(),
      needMoreTeachers: (current.length + unassigned.length) < 2
    };
    this.selectRef = React.createRef();

    this.handleAssignTeacher = this.handleAssignTeacher.bind(this);
    this.handleUnassignTeacher = this.handleUnassignTeacher.bind(this);
  }

  handleAssignTeacher () {
    if (this.selectRef.current != null) {
      const { currentTeachers, unassignedTeachers } = this.state;
      const id = parseInt(this.selectRef.current.value, 10);
      const teacher = unassignedTeachers.find((t: any) => t.id === id);
      const { fromList, toList } = this.moveTeacher(teacher, { fromList: unassignedTeachers, toList: currentTeachers });
      this.setState({
        currentTeachers: toList,
        unassignedTeachers: fromList
      });
      this.props.setCurrentTeachers(toList);
    }
  }

  handleUnassignTeacher (teacher: any) {
    const { currentTeachers, unassignedTeachers } = this.state;
    const confirmation = teacher.id === this.props.portalClassTeacher.id
      ? "This action will remove YOU from this class.\n\nIf you remove yourself, you will lose all access to this class. Are you sure you want to do this?"
      : `This action will remove the teacher: '${teacher.name}' from this class.\n\nAre you sure you want to do this?`;
    if (window.confirm(confirmation)) {
      const { fromList, toList } = this.moveTeacher(teacher, { fromList: currentTeachers, toList: unassignedTeachers });
      this.setState({
        currentTeachers: fromList,
        unassignedTeachers: toList
      });
      this.props.setCurrentTeachers(fromList);
    }
  }

  moveTeacher (teacher: any, lists: any) {
    let { fromList, toList } = lists;
    toList = toList.slice();
    toList.push(teacher);
    toList.sort((a: any, b: any) => a.name.localeCompare(b.name));
    fromList = fromList.filter((t: any) => t.id !== teacher.id);
    return { fromList, toList };
  }

  render () {
    const { needMoreTeachers } = this.state;
    const { currentTeachers, unassignedTeachers } = this.state;

    return (
      <div className="class-teachers">
        <span className="nobreak" id="teacher_add_dropdown">
          {
            unassignedTeachers.length > 0 ?
              <>
                <select id="teacher_id_selector" ref={this.selectRef}>
                  { unassignedTeachers.map((teacher: any) => <option key={teacher.id} value={teacher.id}>{ teacher.name }</option>) }
                </select>
                <input type="button" value="Add" onClick={this.handleAssignTeacher} />
              </>
              :
              <div className="note">
                { needMoreTeachers
                  ? "To share this class with other teachers in your school, first have them create an account. You will then be able to add them here as additional teachers of your class."
                  : "All the teachers from your school have been assigned to the class."
                }
              </div>
          }
        </span>
        <div id="div_teacher_list">
          {
            currentTeachers.length > 0 ?
              <ul>
                { currentTeachers.map((teacher: any) => {
                  let deleteButton;
                  if (currentTeachers.length === 1) {
                    deleteButton = <span><DeleteIcon disabled title="You cannot remove the last teacher from this class." /></span>;
                  } else {
                    deleteButton = <span onClick={() => this.handleUnassignTeacher(teacher)}><DeleteIcon title={`Remove ${teacher.name} from class`} /></span>;
                  }
                  return <li key={teacher.id}>{ teacher.name } { deleteButton }</li>;
                }) }
              </ul>
              : "No teachers are assigned to this class"
          }
        </div>
      </div>
    );
  }
}
