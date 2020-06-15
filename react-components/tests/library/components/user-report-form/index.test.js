/* globals jest describe it expect */
import React from 'react'
import Enzyme from 'enzyme'
import Adapter from 'enzyme-adapter-react-16'
import UserReportForm from 'components/user-report-form'
import ExternalReportButton from 'components/common/external-report-button'
import Select from 'react-select'
import DayPickerInput from 'react-day-picker/DayPickerInput'

Enzyme.configure({adapter: new Adapter()})

// form uses Portal global
global.Portal = {
  API_V1: {
    EXTERNAL_RESEARCHER_REPORT_LEARNER_QUERY: 'http://query-test.concord.org'
  }
}

describe('UserReportForm', () => {
  const externalReports = [{url: 'url1', label: 'label1'}, {url: 'url2', label: 'label2'}]
  const wrapper = Enzyme.shallow(
    <UserReportForm externalReports={externalReports} />
  )

  it('renders custom external report buttons', () => {
    expect(wrapper.find(ExternalReportButton).length).toEqual(2)
    expect(wrapper.find({reportUrl: 'url1', label: 'label1'}).length).toEqual(1)
    expect(wrapper.find({reportUrl: 'url2', label: 'label2'}).length).toEqual(1)
  })

  it('renders filter forms', () => {
    expect(wrapper.text()).toEqual(expect.stringContaining('Teachers'))
    expect(wrapper.text()).toEqual(expect.stringContaining('Cohorts'))
    expect(wrapper.text()).toEqual(expect.stringContaining('Runnables'))
    expect(wrapper.find(Select).length).toEqual(3)

    expect(wrapper.text()).toEqual(expect.stringContaining('Earliest date'))
    expect(wrapper.text()).toEqual(expect.stringContaining('Latest date'))
    expect(wrapper.find(DayPickerInput).length).toEqual(2)
  })
})
