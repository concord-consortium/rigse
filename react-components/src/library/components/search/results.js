import React from 'react'

import { SGenericLink } from './material-links'
import SearchResultGroup from './result-group'

export default class SearchResults extends React.Component {
  generateScrollTo (type) {
    return event => window.scrollTo(0, jQuery(`${type}_bookmark`).offsetTop)
  }

  renderMessage () {
    return this.props.results.map((group, idx) => {
      const link = { url: '#', onclick: this.generateScrollTo(group.type), text: group.header, className: '' }
      return (
        <span key={group.type}>
          {group.pagination.total_items}
          {' '}
          <SGenericLink link={link} />
          {idx !== (this.props.results.length - 1) ? ', ' : ''}
        </span>
      )
    })
  }

  renderAllResults () {
    return this.props.results.map((group) => <SearchResultGroup group={group} key={group.type} />)
  }

  renderSearchTerm () {
    if (jQuery('#search_term').val().length > 0) {
      return ` search term "${jQuery('#search_term').val()}" and`
    } else {
      return ''
    }
  }

  render () {
    return (
      <div id='offering_list'>
        <p style={{ fontWeight: 'bold' }}>
          {this.renderMessage()}
          {' matching '}
          {this.renderSearchTerm()}
          {' selected criteria'}
        </p>
        <div className='results_container'>
          {this.renderAllResults()}
        </div>
      </div>
    )
  }
}
