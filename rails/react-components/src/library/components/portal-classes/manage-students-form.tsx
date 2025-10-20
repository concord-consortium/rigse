import React, { useEffect } from "react";
import TriStateCheckbox from "../common/tri-state-checkbox";
import apiPost from "../../helpers/api/post";

import css from "./manage-students-form.scss";

interface ManageStudentsFormProps {
  students: any[];
  totalStudents: number;
  className: string;
  classId: number
  teacherIds: string[];
  onFormClose: () => void;
}

function errorWithMessage(error: unknown): error is { message: string } {
  return typeof error === "object" &&
    error !== null &&
    "message" in error &&
    typeof (error as any).message === "string";
}

export const ManageStudentsForm = (
  { students, totalStudents, className, classId, teacherIds, onFormClose }: ManageStudentsFormProps
) => {
  const [classes, setClasses] = React.useState<any[] | undefined>(undefined);
  const [classFetchError, setClassFetchError] = React.useState<string | undefined>(undefined);
  const [selectedClasses, setSelectedClasses] = React.useState<{ [key: string]: boolean }>({});
  const [addStudentsError, setAddStudentsError] = React.useState<string | undefined>(undefined);
  const [addStudentsProgress, setAddStudentsProgress] = React.useState<string>("");

  const numSelectedClasses = Object.keys(selectedClasses).length;

  useEffect(() => {
    const abortController = new AbortController();
    let isMounted = true;

    // We could almost use api/v1/research_classes enpoint and pass it an array
    // of teachers, but it requires a project_id which we don't have
    const fetchData = async () => {
      const results = [];
      for (const id of teacherIds) {
        try {
          const result = await fetch(`/api/v1/teachers/${id}/classes`, {
            signal: abortController.signal
          });
          // If the user doesn't have access to this teacher the response
          // will not be ok, so we just skip it.
          if (!result.ok) continue;
          // The returned class objects don't have have the list of teachers
          // We could add the current teacherId to each class object, but
          // if the current user doesn't have access to the other other teachers
          // in the class then the list of teachers will be incomplete.
          // So instead we ignore the teacherIds for now.
          results.push(await result.json());
        } catch (error) {
          if (abortController.signal.aborted) {
            // Fetch was aborted, bail out of the loop
            return undefined;
          }
          console.error("Error fetching classes for teacher", id, error);
          setClassFetchError(`Error fetching classes for teacher ${id}` +
            (errorWithMessage(error) ? `: ${error.message}` : ""));
        }
      }

      // We were disposed, so just return with changing state
      if (!isMounted || abortController.signal.aborted) return;

      // make the results unique by id, and for duplicates join the teacherIds
      const uniqueClasses: any[] = [];
      results.flat().forEach((currentClass) => {
        if (currentClass == null) return;
        // Skip the class the manage students form is being shown for
        if (currentClass.id == classId) return;
        if (uniqueClasses.find((item:any) => item.id === currentClass.id)) return;
        uniqueClasses.push(currentClass);
      });
      setClasses(uniqueClasses);
    }
    fetchData();
    return () => {
      isMounted = false;
      abortController.abort();
    };
  }, [teacherIds]);

  const addStudentsToSelectedClasses = async () => {
    const errorsAddingStudents: any[] = [];
    const totalChanges = students.length * numSelectedClasses;
    let changesCompleted = 0;

    const updateProgress = () => {
      setAddStudentsProgress(`Adding students to classes... ${changesCompleted} of ${totalChanges} changes completed.`);
    };

    updateProgress();

    for (const student of students) {
      for (const [clazzId, shouldBeInClass] of Object.entries(selectedClasses)) {
        if (!shouldBeInClass) continue;

        await new Promise((resolve) =>
          apiPost("/api/v1/students/add_to_class", {
            data: {
              clazz_id: clazzId,
              student_id: student.student_id
            },
            onError: (error: any) => {
              const info = { error, clazzId, studentId: student.student_id };
              console.error("Error adding student to class", info);
              errorsAddingStudents.push(info);
              resolve(null);
            },
            onSuccess: () => {
              console.log("added student to class",
                { clazzId, studentId: student.student_id });
              resolve(null);
            }
          })
        );
        changesCompleted++;
        updateProgress();
      }
    }

    if (errorsAddingStudents.length) {
      setAddStudentsError(`There were ${errorsAddingStudents.length} errors adding students to classes. See console for details.`);
      return;
    }

    onFormClose();
  };

  const renderClasses = () => {
    if (classFetchError) {
      return classFetchError;
    }

    if (classes == null) {
      return "Loading classes...";
    }

    if (classes.length === 0) {
      return "No classes found for the selected teachers.";
    }
    return (
      <ul className={css.classList}>
        {classes.map((c) => (
          <li key={c.id}>
            <TriStateCheckbox
              label={`${c.name} (id: ${c.id})`}
              checked={selectedClasses[c.id] || false}
              onChange={(newState) => {
              setSelectedClasses((prevState) => ({
                ...prevState,
                [c.id]: newState
              }));
            }}/>
          </li>
        ))}
      </ul>
    );
  };

  return (
    <div className={css.manageStudentsForm}>
      <div className={css.formTop}>
        Manage Students
      </div>
      <div className={css.formRow}>
        <span className={css.contextInfo}>
          {students.length} of {totalStudents} students selected from {className}.
        </span>
        { addStudentsError &&
          <div>
            {addStudentsError}
          </div>
        }
        { addStudentsProgress &&
          <div>
            {addStudentsProgress}
          </div>
        }
      </div>
      <div className={css.formRow}>
        Select class(es) to add student(s) to:
      </div>
      <div className={classNames([css.formRow, css.classListRow])}>
        {renderClasses()}
      </div>
      <div className={css.formRow}>
        <em className={css.note}>
          Note: Student's assignments from this class will not be added to the new classes.
          Only student names will be added to roster.
        </em>
      </div>
      <div className={css.formButtonArea}>
        <button className={css.cancelButton} onClick={onFormClose}>
          Cancel
        </button>
        <button onClick={addStudentsToSelectedClasses} disabled={numSelectedClasses === 0 || !!addStudentsProgress}>
          Add Students
        </button>
      </div>
    </div>
  );
}
