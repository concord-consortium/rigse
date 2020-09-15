import React from 'react'

import StandardsTable from '../standards/standards-table'

import css from './add-standard.scss'

export class AddStandard extends React.Component {
  constructor (props) {
    super(props)
    this.state = {
      searched: false,
      searching: false,
      standards: undefined,
      loadedStandards: false,
      searchError: undefined
    }

    this.search = this.search.bind(this)

    this.handleSearch = this.handleSearch.bind(this)
    this.handleCheckEnter = this.handleCheckEnter.bind(this)

    this.standardDocRef = React.createRef()
    this.notationRef = React.createRef()
    this.labelRef = React.createRef()
    this.descriptionRef = React.createRef()
    this.uriRef = React.createRef()
  }

  // eslint-disable-next-line camelcase
  UNSAFE_componentWillReceiveProps (nextProps) {
    // redo the search when the applied standards change as the user can toggle them in that list
    if (this.state.searched && (this.props.appliedStandardsChangedAt !== nextProps.appliedStandardsChangedAt)) {
      this.search()
    }
  }

  handleCheckEnter (e) {
    if (e.keyCode === 13) {
      this.handleSearch()
      e.preventDefault()
    }
  }

  handleSearch () {
    this.search()
  }

  search (startIndex) {
    const { materialInfo } = this.props

    this.setState({ searched: true, searching: true, loadedStandards: false, standards: undefined }, () => {
      const data = {
        asn_document_id: this.standardDocRef.current.value,
        asn_statement_notation_query: this.notationRef.current.value,
        asn_statement_label_query: this.labelRef.current.value,
        asn_description_query: this.descriptionRef.current.value,
        asn_uri_query: this.uriRef.current.value,
        ...materialInfo
      }

      if (startIndex) {
        data.start = startIndex
      }

      jQuery.ajax({
        type: 'GET',
        dataType: 'json',
        url: '/api/v1/materials/get_standard_statements',
        data: data,
        success: (response) => {
          if (response) {
            response.material = materialInfo
          }

          this.setState({
            searching: false,
            loadedStandards: true,
            standards: response,
            searchError: undefined
          })
        },
        error: function (xhr, ajaxOptions, thrownError) {
          this.setState({
            searching: false,
            loadedStandards: true,
            searchError: xhr.responseText
          })
        }
      })
    })
  }

  renderSearchResults () {
    const { afterChange } = this.props
    const { searching, loadedStandards, standards, searchError } = this.state

    if (searching || !loadedStandards) {
      return undefined
    }

    if (searchError) {
      return <div className={css.error}>{searchError}</div>
    }

    return <StandardsTable search={this.search} afterChange={afterChange} skipModal {...standards} />
  }

  render () {
    const { searching } = this.state
    const { allStandards } = this.props

    return (
      <div>
        <table className={css.table} onKeyDown={this.handleCheckEnter}>
          <tbody>
            <tr>
              <td>Standard Document</td>
              <td>
                <select ref={this.standardDocRef}>
                  {allStandards.map((s) => <option key={s.name} value={s.uri}>{s.name}</option>)}
                </select>
              </td>
            </tr>

            <tr>
              <td>Notation</td>
              <td><input type='text' ref={this.notationRef} /></td>
            </tr>

            <tr>
              <td>Label</td>
              <td><input type='text' ref={this.labelRef} /></td>
            </tr>

            <tr>
              <td>Description</td>
              <td><input type='text' ref={this.descriptionRef} /></td>
            </tr>

            <tr>
              <td>URI</td>
              <td>
                <input type='text' ref={this.uriRef} />
              </td>
            </tr>
          </tbody>
        </table>

        <div className={css.button}>
          <button onClick={this.handleSearch} disabled={searching}>{searching ? 'Searching...' : 'Search'}</button>
        </div>

        {this.renderSearchResults()}
      </div>
    )
  }
}

export default AddStandard
