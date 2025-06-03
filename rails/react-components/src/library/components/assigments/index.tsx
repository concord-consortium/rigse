import React from "react";
import ClassAssignments from "./class-assignments";
import { reportableActivityMapping, studentMapping } from "../common/offering-progress/helpers";
import sortByName from "../../helpers/sort-by-name";
import OfferingsTable from "./offerings-table";
import { arrayMove } from "@dnd-kit/sortable";
import { appendOfferingApiQueryParams } from "../../url-params";

const addQueryParam = (url: any, param: any, value: any) => {
  const urlObj = new URL(url);
  urlObj.searchParams.append(param, value);
  return urlObj.toString();
};

const teachersMapping = (data: any) => {
  return data.map((teacher: any) => `${teacher.first_name} ${teacher.last_name}`).join(", ");
};

const offeringsListMapping = (data: any) => {
  return data.map((offering: any) => ({
    id: offering.id,
    name: offering.name,
    apiUrl: offering.url,
    locked: offering.locked,
    active: offering.active,
    metadata: offering.metadata,
  }));
};

const externalReportMapping = (data: any, researcher?: any) => {
  if (!data) {
    return null;
  }
  return {
    name: data.name,
    launchText: data.launch_text,
    url: researcher ? addQueryParam(data.url, "researcher", "true") : data.url
  };
};

const externalReportsArrayMapping = (data: any, researcher?: any) => {
  if (!data) {
    return [];
  }
  return (researcher ? data.filter((r: any) => r.supports_researchers) : data).map((r: any) => externalReportMapping(r, researcher));
};

const classMapping = (data: any, researcher?: any) => {
  return data && {
    id: data.id,
    name: data.name,
    classWord: data.class_word,
    classHash: data.class_hash,
    teachers: teachersMapping(data.teachers),
    editPath: data.edit_path,
    assignMaterialsPath: data.assign_materials_path,
    externalClassReports: externalReportsArrayMapping(data.external_class_reports, researcher)
  };
};

const offeringDetailsMapping = (data: any, researcher: any) => {
  return {
    id: data.id,
    activityName: data.activity,
    previewUrl: data.preview_url,
    activityUrl: data.activity_url,
    hasTeacherEdition: data.has_teacher_edition,
    reportUrl: data.report_url,
    externalReports: externalReportsArrayMapping(data.external_reports, researcher),
    reportableActivities: data.reportable_activities?.map((a: any) => reportableActivityMapping(a)),
    students: data.students.map((s: any) => studentMapping(s, researcher)).sort(sortByName)
  };
};

export default class Assignments extends React.Component<any, any> {
  static defaultProps = {
    // classDataUrl is pretty much required. It can be set to any default value, as it depends on the current class.
    classDataUrl: null,
    // When user is a researcher, this component should be read-only.
    researcher: false,
    // If initialData is not provided, component will use API (dataUrl) to get it.
    initialClassData: null
  };

  constructor (props: any) {
    super(props);
    this.state = {
      loading: !props.initialClassData,
      clazz: classMapping(props.initialClassData),
      // List of offering metadata.
      offerings: props.initialClassData ? offeringsListMapping(props.initialClassData.offerings) : [],
      // Detailed offering data which can be used to generate progress report.
      offeringDetails: {}
    };
    this.onOfferingsReorder = this.onOfferingsReorder.bind(this);
    this.onOfferingUpdate = this.onOfferingUpdate.bind(this);
    this.requestOfferingDetails = this.requestOfferingDetails.bind(this);
    this.handleNewAssignments = this.handleNewAssignments.bind(this);
    this.onSetStudentOfferingMetadata = this.onSetStudentOfferingMetadata.bind(this);
  }

  componentDidMount () {
    const { classDataUrl, initialClassData } = this.props;
    if (classDataUrl && !initialClassData) {
      this.getClassData();
    }
  }

  getClassData () {
    const { classDataUrl } = this.props;
    jQuery.ajax({
      url: classDataUrl,
      success: data => {
        this.setState({
          loading: false,
          clazz: classMapping(data),
          offerings: offeringsListMapping(data.offerings)
        });
      },
      error: () => {
        console.error(`GET ${classDataUrl} failed, can't render Assignment page`);
      }
    });
  }

  onOfferingsReorder ({
    oldIndex,
    newIndex
  }: any) {
    if (oldIndex === newIndex) {
      return;
    }
    const { offerings } = this.state;
    const offeringApiUrl = offerings[oldIndex].apiUrl;
    this.setState({ offerings: arrayMove(offerings, oldIndex, newIndex) });
    jQuery.ajax({
      type: "PUT",
      url: offeringApiUrl,
      data: {
        position: newIndex
      },
      error: () => {
        window.alert("Reordering failed, please try to reload page and try again.");
        this.setState({ offerings });
      }
    });
  }

  onOfferingUpdate (offering: any, prop: any, value: any) {
    const { offerings } = this.state;
    const newOffering = { ...offering, [prop]: value };

    // when setting active or locked, we also set all students in the offering to that value
    // overriding any previous values
    if (["active", "locked"].includes(prop)) {
      newOffering.metadata = newOffering.metadata.map((m: any) => {
        m[prop] = value;
        return m;
      });

      const offeringDetails = this.state.offeringDetails[offering.id];
      if (offeringDetails) {
        const newStudents = offeringDetails.students.map((s: any) => ({ ...s, [prop]: value }));
        const newOfferingDetails = { ...offeringDetails, students: newStudents };
        this.setState((prevState: any) => ({
          offeringDetails: { ...prevState.offeringDetails, [offering.id]: newOfferingDetails }
        }));
      }
    }

    const newOfferings = offerings.slice();
    newOfferings.splice(offerings.indexOf(offering), 1, newOffering);
    this.setState({ offerings: newOfferings });

    jQuery.ajax({
      type: "PUT",
      url: offering.apiUrl,
      data: {
        [prop]: value
      },
      error: () => {
        window.alert("Offering update failed, please try to reload page and try again.");
      }
    });
  }

  onSetStudentOfferingMetadata (studentId: any, offeringId: any, metadata: any) {
    this.setState((prevState: any) => {
      const { offerings } = prevState;
      const offering = offerings.find((o: any) => o.id === offeringId);
      const offeringDetails = prevState.offeringDetails[offeringId];

      if (!offeringDetails || !offering) {
        // sanity check, if offeringDetails or offering is not found, do nothing
        return prevState;
      }

      const { active, locked } = metadata;
      const { students } = offeringDetails;
      const currentStudent = students.find((s: any) => s.id === studentId);
      const newCurrentStudent = { ...currentStudent, active, locked };
      const newStudents = students.map((s: any) => s.id === studentId ? newCurrentStudent : s);
      const newOfferingDetails = { ...offeringDetails, students: newStudents };
      const newOffering = { ...offering };

      // if all the students are set to the same values, update the offering metadata
      // in both the UI and on the server
      const allSameActive = newStudents.every((s: any) => s.active === active);
      const allSameLocked = newStudents.every((s: any) => s.locked === locked);
      const data: Record<string, boolean> = {};
      if (allSameActive) {
        newOffering.active = active;
        data.active = active;
      }
      if (allSameLocked) {
        newOffering.locked = locked;
        data.locked = locked;
      }
      if (allSameActive || allSameLocked) {
        jQuery.ajax({type: "PUT", url: newOffering.apiUrl, data});
      }

      newOffering.metadata = newStudents.map((s: any) => ({
        user_id: s.id,
        active: s.active,
        locked: s.locked
      }));
      const newOfferings = offerings.map((o: any) => o.id === offeringId ? newOffering : o);

      return {
        offeringDetails: { ...prevState.offeringDetails, [offeringId]: newOfferingDetails },
        offerings: newOfferings
      };
    });
  }

  requestOfferingDetails (offering: any) {
    const { researcher } = this.props;

    jQuery.ajax({
      type: "GET",
      url: appendOfferingApiQueryParams(offering.apiUrl, researcher ? { researcher: true } : {}),
      success: data => {
        const newData = offeringDetailsMapping(data, researcher);
        const { offeringDetails } = this.state;
        this.setState({
          offeringDetails: { ...offeringDetails, [offering.id]: newData }
        });
      },
      error: () => {
        window.alert("Offering details loading failed, please try to reload page and try again.");
      }
    });
  }

  handleNewAssignments () {
    this.getClassData();
  }

  render () {
    const { researcher } = this.props;
    const { loading, clazz, offerings, offeringDetails } = this.state;
    if (loading) {
      return null;
    }
    return (
      <div>
        <ClassAssignments clazz={clazz} handleNewAssignment={this.handleNewAssignments} />
        <OfferingsTable
          offerings={offerings}
          offeringDetails={offeringDetails}
          clazz={clazz}
          readOnly={researcher}
          requestOfferingDetails={this.requestOfferingDetails}
          onOfferingsReorder={this.onOfferingsReorder}
          onOfferingUpdate={this.onOfferingUpdate}
          onSetStudentOfferingMetadata={this.onSetStudentOfferingMetadata}
        />
      </div>
    );
  }
}
