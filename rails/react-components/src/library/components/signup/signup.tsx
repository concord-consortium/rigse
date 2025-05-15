import React from "react";

import StudentForm from "./student_form";
import TeacherForm from "./teacher_form";
import BasicDataForm from "./basic_data_form";
import StudentRegistrationComplete from "./student_registration_complete";
import TeacherRegistrationComplete from "./teacher_registration_complete";
import UserTypeSelector from "./user_type_selector";
import AlreadyHaveAccount from "./already_have_account";
import Modal from "../../helpers/modal";

export default class SignUp extends React.Component<any, any> {
  static defaultProps = {
    siteName: (window.Portal?.siteName) || "Portal",
    signupText: "Next",
    anonymous: window.Portal?.currentUser.isAnonymous
  };

  constructor (props: any) {
    super(props);
    this.state = {
      userType: null,
      basicData: null,
      studentData: null,
      teacherData: null,
    };

    this.onUserTypeSelect = this.onUserTypeSelect.bind(this);
    this.onBasicDataSubmit = this.onBasicDataSubmit.bind(this);
    this.onStudentRegistration = this.onStudentRegistration.bind(this);
    this.onTeacherRegistration = this.onTeacherRegistration.bind(this);
  }

  onUserTypeSelect (data: any) {
    const url = new URL(window.location.href);
    url.searchParams.set("userType", data);
    const newUrl = url.toString();

    window.history.pushState({ path: newUrl }, "", newUrl);
    this.setState({
      userType: data
    });
  }

  onBasicDataSubmit (data: any) {
    const {pathname, search} = window.location;
    data.sign_up_path = `${pathname}${search}`;
    this.setState({
      basicData: data
    });
  }

  onStudentRegistration (data: any) {
    this.setState({
      studentData: data
    });
  }

  onTeacherRegistration (data: any) {
    this.setState({
      teacherData: data
    });
  }

  getStepNumber () {
    const { basicData, studentData, teacherData } = this.state;

    if (!this.props.omniauth && !basicData) {
      return 1;
    }
    if (this.props.omniauth || (basicData && !studentData && !teacherData)) {
      return 2;
    }
    return 3;
  }

  render () {
    const { signupText, oauthProviders, anonymous, omniauthOrigin, loginUrl, classWord } = this.props;
    const { userType, basicData, studentData, teacherData } = this.state;

    let form;

    //
    // For omniauth final step, simply redirect to omniauth_origin
    //
    if ((studentData || teacherData) && this.props.omniauth) {
      const data = this.state.studentData ? this.state.studentData : this.state.teacherData;
      window.location.href = data.omniauth_origin;
      return null;
    }

    if (studentData) {
      //
      // Display completion step
      //
      form = <StudentRegistrationComplete anonymous={anonymous} data={studentData} loginUrl={loginUrl} />;
    } else if (teacherData) {
      //
      // Display completion step
      //

      // don't allow the user to close the modal, otherwise a blank page will be shown in certain cases
      Modal.disableHide(true);

      form = <TeacherRegistrationComplete anonymous={anonymous} loginUrl={loginUrl} />;
    } else if (omniauthOrigin != null) {
      if (omniauthOrigin.search("teacher") > -1) {
        form = <TeacherForm
          anonymous={this.props.anonymous}
          basicData={basicData}
          onRegistration={this.onTeacherRegistration}
        />;
      } else if (omniauthOrigin.search("student") > -1) {
        form = <StudentForm
          basicData={basicData}
          onRegistration={this.onStudentRegistration}
          classWord={classWord}
        />;
      }
    } else if (!userType) {
      // studentReg: this.onStudentRegistration,
      // teacherReg: this.onTeacherRegistration,
      form = <UserTypeSelector
        anonymous={anonymous}
        oauthProviders={oauthProviders}
        onUserTypeSelect={this.onUserTypeSelect}
        loginUrl={loginUrl}
      />;
    } else if (basicData) {
      if (userType === "teacher") {
        form = <TeacherForm
          anonymous={this.props.anonymous}
          basicData={basicData}
          onRegistration={this.onTeacherRegistration}
        />;
      } else {
        form = <StudentForm
          basicData={basicData}
          onRegistration={this.onStudentRegistration}
          classWord={classWord}
        />;
      }
    } else {
      form = <BasicDataForm
        anonymous={anonymous}
        userType={userType}
        signupText={signupText}
        oauthProviders={oauthProviders}
        onSubmit={this.onBasicDataSubmit}
      />;
    }

    let formTitle: JSX.Element
    if (studentData) {
      // note: this isn't done for teachers as they don't get a login form at the end of the registration process
      // but rather a final dialog that tells them to check their email
      formTitle = <h2><strong>Log In</strong><br /> to the { this.props.siteName }</h2>
    } else if (anonymous) {
      const formTitleIntro = this.state.userType != null
        ? `Create a ${userType.charAt(0).toUpperCase() + userType.slice(1)} Account`
        : "Create an Account";
      formTitle = <h2><strong>{ formTitleIntro }</strong><br/> for the { this.props.siteName }</h2>
    } else {
      formTitle = <h2><strong>Finish</strong> Signing Up</h2>;
    }

    // don't show the already have account link if the user has finished the student or teacher registration process
    const hideAlreadyHaveAccount = studentData || teacherData;

    return (
      <div>
        { formTitle }
        <div className="signup-form">
          { form }
          {!hideAlreadyHaveAccount && <AlreadyHaveAccount oauthProviders={oauthProviders} loginUrl={loginUrl} />}
        </div>
        <footer className="reg-footer">
          <p><strong>Why sign up?</strong> It’s free and you get access to bonus features! <strong>Students</strong> can save their work and get feedback from their teachers. <strong>Teachers</strong> can create classes, assign activities, track student progress, and more!</p>
        </footer>
      </div>
    );
  }
}
