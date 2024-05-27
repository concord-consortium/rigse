import React from "react";

import css from "./style.scss";

export const ENTER_CLASS_WORD = "enterClassWord";
export const CONFIRMING_CLASS_WORD = "confirmClassWord";
export const JOIN_CLASS = "joinClass";
export const JOINING_CLASS = "joiningClass";

export class JoinClass extends React.Component<any, any> {
  classWordRef: any;
  constructor (props: any) {
    super(props);
    this.state = {
      classWord: "",
      error: null,
      teacherName: null,
      formState: "enterClassWord"
    };

    this.handleSubmit = this.handleSubmit.bind(this);
    this.handleCancelJoin = this.handleCancelJoin.bind(this);

    this.classWordRef = React.createRef();
  }

  handleCancelJoin () {
    this.setState({ formState: ENTER_CLASS_WORD });
  }

  handleSubmit (e: any) {
    e.preventDefault();

    let { formState, classWord } = this.state;

    const onError = (err: any) => {
      this.setState({ error: err.message || "Unable to join class!" });
      this.setState({ formState: ENTER_CLASS_WORD });
    };

    switch (formState) {
      case ENTER_CLASS_WORD:
        classWord = this.classWordRef.current ? this.classWordRef.current.value.trim() : "";
        if (classWord.length > 0) {
          this.setState({ formState: CONFIRMING_CLASS_WORD }, () => {
            const onSuccess = (result: any) => this.setState({ error: null, classWord, teacherName: result.teacher_name, formState: JOIN_CLASS });
            this.apiCall("confirm", { data: { class_word: classWord }, onSuccess, onError });
          });
        }
        break;

      case JOIN_CLASS:
        this.setState({ formState: JOINING_CLASS }, () => {
          const onSuccess = () => this.props.afterJoin();
          this.apiCall("join", { data: { class_word: classWord }, onSuccess, onError });
        });
        break;
    }
  }

  showError (err: any, message: any) {
    this.setState({ error: err.message || message });
  }

  apiCall (action: any, options: any) {
    const basePath = "/api/v1/students";
    const { data, onSuccess, onError } = options;

    // @ts-expect-error TS(7053): Element implicitly has an 'any' type because expre... Remove this comment to see the full error message
    const { url, type } = {
      confirm: { url: `${basePath}/confirm_class_word`, type: "POST" },
      join: { url: `${basePath}/join_class`, type: "POST" }
    }[action];

    jQuery.ajax({
      url,
      data: JSON.stringify(data),
      type,
      dataType: "json",
      contentType: "application/json",
      success: json => {
        if (!json.success) {
          onError?.(json);
        } else {
          onSuccess?.(json.data);
        }
      },
      error: (jqXHR, textStatus, error) => {
        try {
          error = JSON.parse(jqXHR.responseText);
        } catch (e) {
          // noop
        }
        onError?.(error);
      }
    });
  }

  renderEnterClassWord () {
    const { formState } = this.state;
    const confirmingClassWord = formState === CONFIRMING_CLASS_WORD;

    return (
      <>
        <ul>
          <li>
            <label htmlFor="classWord">New Class Word: </label>
            <p>Not case sensitive</p>
            <input type="text" id="classWord" name="classWord" ref={this.classWordRef} size={30} disabled={confirmingClassWord} />
          </li>
          <li>
            <input type="submit" disabled={confirmingClassWord} value={confirmingClassWord ? "Submitting ..." : "Submit"} />
          </li>
        </ul>
        <p>
          A Class Word is created by a Teacher when he or she creates a new class.
          If you have been given the Class Word you can enter that word here to become a member of that class.
        </p>
      </>
    );
  }

  renderJoinClass () {
    const { teacherName, formState } = this.state;
    const { allowDefaultClass } = this.props;
    const joiningClass = formState === JOINING_CLASS;

    return (
      <>
        <p>
          { allowDefaultClass
            ? `By joining this class, the teacher ${teacherName} will be able to see all of your current and future work. If do not want to share your work, but do want to join the class please create a second account and use it to join the class.`
            : `The teacher of this class is ${teacherName}. Is this the class you want to join?`
          }
        </p>
        <p>
          Click 'Join' to continue registering for this class.
        </p>
        <p>
          <input type="submit" disabled={joiningClass} value={joiningClass ? "Joining ..." : "Join"} />
          <button name="Cancel" onClick={this.handleCancelJoin}>Cancel</button>
        </p>
      </>
    );
  }

  render () {
    const { error, formState } = this.state;

    return (
      <form className={css.form} onSubmit={this.handleSubmit}>
        <fieldset>
          { error
            ? <p className={css.error}>{ error.toString() }</p>
            : undefined
          }
          <legend>Class Word</legend>
          { (formState === ENTER_CLASS_WORD) || (formState === CONFIRMING_CLASS_WORD)
            ? this.renderEnterClassWord()
            : this.renderJoinClass()
          }
        </fieldset>
      </form>
    );
  }
}

export default JoinClass;
