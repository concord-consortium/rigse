import React from 'react'
import Select from 'react-select'
import { withFormsy } from 'formsy-react'

var TIMEOUT = 500

const getSchools = (country, zipcode) => jQuery.get(Portal.API_V1.SCHOOLS + '?country_id=' + country + '&zipcode=' + zipcode)

class SchoolInput extends React.Component {
  constructor (props) {
    super(props)
    this.state = {
      isLoading: false,
      options: []
    }
    this.changeValue = this.changeValue.bind(this)
  }

  componentDidMount () {
    this.updateOptions()
  }

  componentDidUpdate (prevProps) {
    const { country, zipcode } = this.props
    if (prevProps.country !== country || prevProps.zipcode !== zipcode) {
      this.props.setValue('')
      this.updateOptions()
    }
  }

  newSchoolLink () {
    return <div className='new-school-link' onClick={this.props.onAddNewSchool}>Add a new school</div>
  }

  changeValue (option) {
    this.props.setValue(option && option.value)
  }

  updateOptions () {
    const { country, zipcode } = this.props
    if ((country == null) || (zipcode == null)) {
      return
    }
    if (this.timeoutID) {
      window.clearTimeout(this.timeoutID)
    }
    this.setState({
      isLoading: true
    })
    this.timeoutID = window.setTimeout(() => {
      getSchools(country, zipcode).done(function (data) {
        const options = data.map(school => ({ label: school.name, value: school.id }))
        options.push({
          label: this.newSchoolLink(),
          disabled: true
        })
        this.setState({
          options: options,
          isLoading: false
        })
      })
    }, TIMEOUT)
  }

  render () {
    let className = 'select-input'
    const { placeholder, disabled } = this.props
    const { options, isLoading } = this.state

    if (this.props.value) {
      className += ' valid'
    }

    const noResultsText = <div><div>No schools found</div>{this.newSchoolLink()}</div>

    return (
      <div className={className}>
        <Select
          placeholder={placeholder}
          options={options}
          isLoading={isLoading}
          disabled={disabled}
          value={this.props.value || ''}
          onChange={this.changeValue}
          clearable={false}
          noResultsText={noResultsText}
        >
          <div className='input-error'>
            {this.props.errorMessage}
          </div>
        </Select>
      </div>
    )
  }
}

export default withFormsy(SchoolInput)
