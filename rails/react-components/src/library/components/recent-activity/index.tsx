import React from "react";
import Offerings from "./offerings";
import { reportableActivityMapping, studentMapping } from "../common/offering-progress/helpers";
import { appendOfferingApiQueryParams } from "../../url-params";

const externalReportMapping = (data: any) => {
  if (!data) {
    return null;
  }
  return {
    url: data.url,
    launchText: data.launch_text,
    supportsResearchers: data.supports_researchers
  };
};

const offeringMapping = (data: any) => {
  const lastRunDates = data.students
    // Filter out offerings that have never been run.
    .filter((s: any) => s.last_run !== null)
    .map((s: any) => new Date(s.last_run));
  const notStartedStudentsCount = data.students
    .filter((s: any) => !s.started_activity)
    .length;
  const startedStudentsCount = data.students
    .filter((s: any) => s.started_activity)
    .length;
  return {
    id: data.id,
    clazz: data.clazz,
    classHash: data.clazz_hash,
    activityName: data.activity,
    previewUrl: data.preview_url,
    activityUrl: data.activity_url,
    hasTeacherEdition: data.has_teacher_edition,
    lastRun: lastRunDates.length > 0 ? lastRunDates[0] : null,
    notStartedStudentsCount,
    startedStudentsCount,
    reportUrl: data.report_url,
    externalReports: data.external_reports?.map((r: any) => externalReportMapping(r)),
    reportableActivities: data.reportable_activities?.map((a: any) => reportableActivityMapping(a)),
    students: data.students.map((s: any) => studentMapping(s))
  };
};

const processAPIData = (data: any) => {
  return data?.map((offering: any) => offeringMapping(offering)).filter((offering: any) => offering.lastRun !== null).sort((o1: any, o2: any) => o2.lastRun - o1.lastRun); // Sort by lastRun, DESC order
};

// Checks if the teacher has any classes.
const hasAnyClasses = (data: any) => data && data.length > 0;
// Checks if there is any data available.
const hasAnyData = (data: any) => data && data.length > 0;
// Checks if there are any students assigned to some offering.
const hasAnyStudents = (data: any) => data && data.map((o: any) => o.students.length).filter((count: any) => count > 0).length > 0;

export default class RecentActivity extends React.Component<any, any> {
  static defaultProps = {
    // This path will return all the offerings for logged in user. Portal will probably explicitly limit scope
    // of offerings by providing custom path with user_id param.
    dataUrl: Portal.API_V1.OFFERING,
    // If initialData is not provided, component will use API (dataUrl) to get it.
    initialData: null,
    // Set updateInterval to null to disable updates at all.
    updateInterval: 300000 // ms
  };

  intervalId: any;
  constructor (props: any) {
    super(props);
    this.state = {
      loading: !props.initialData,
      anyClasses: null,
      anyData: hasAnyData(props.initialData),
      anyStudents: hasAnyStudents(props.initialData),
      offerings: processAPIData(props.initialData)
    };
    this.getPortalData = this.getPortalData.bind(this);
  }

  componentDidMount () {
    const { dataUrl, initialData, updateInterval } = this.props;
    if (dataUrl && !initialData) {
      this.getPortalData();
    }
    if (updateInterval) {
      this.intervalId = window.setInterval(this.getPortalData, updateInterval);
    }
  }

  componentWillUnmount () {
    if (this.intervalId) {
      window.clearInterval(this.intervalId);
    }
  }

  getPortalData () {
    const { dataUrl } = this.props;
    jQuery.ajax({
      url: "/api/v1/classes/mine",
      success: data => {
        this.setState({
          anyClasses: hasAnyClasses(data.classes)
        });
      },
      error: () => {
        console.error(`GET class data failed, can't render Recent Activity page`);
      }
    });

    jQuery.ajax({
      url: appendOfferingApiQueryParams(dataUrl),
      success: data => {
        this.setState({
          loading: false,
          // Note that processAPIData will skip offerings that have been never run by any student.
          offerings: processAPIData(data),
          // So, we need some additional variables:
          anyData: hasAnyData(data),
          anyStudents: hasAnyStudents(data)
        });
      },
      error: () => {
        console.error(`GET ${dataUrl} failed, can't render Recent Activity page`);
      }
    });
  }

  render () {
    const { loading, offerings, anyClasses, anyData, anyStudents } = this.state;
    if (loading) {
      return null;
    }
    return (
      <Offerings anyClasses={anyClasses} anyData={anyData} anyStudents={anyStudents} offerings={offerings} />
    );
  }
}
