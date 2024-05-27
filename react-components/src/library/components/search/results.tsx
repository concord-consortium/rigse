import React from 'react'

import { SGenericLink } from './material-links'
import SearchResultGroup from './result-group'

export default class SearchResults extends React.Component<any, any> {
  generateScrollTo (type: any) {
    // @ts-expect-error TS(2339): Property 'offsetTop' does not exist on type 'JQuer... Remove this comment to see the full error message
    return (event: any) => window.scrollTo(0, jQuery(`${type}_bookmark`).offsetTop);
  }

  renderMessage () {
    return this.props.results.map((group: any, idx: any) => {
      const link = { url: '#', onclick: this.generateScrollTo(group.type), text: group.header, className: '' }
      return (
        <span key={group.type}>
          {group.pagination.total_items}
          {' '}
          <SGenericLink link={link} />
          {idx !== (this.props.results.length - 1) ? ', ' : ''}
        </span>
      )
    });
  }

  renderAllResults () {
    return this.props.results.map((group: any) => <SearchResultGroup group={group} key={group.type} />);
  }

  renderSearchTerm () {
    const searchTerm = jQuery('#search_term')
    // @ts-expect-error TS(2532): Object is possibly 'undefined'.
    if (searchTerm.length > 0 && searchTerm.val().length > 0) {
      return ` search term "${jQuery('#search_term').val()}" and`
    } else {
      return ''
    }
  }

  render () {
    return (
      <div id='offering_list' data-testid='offering-list'>
        <p style={{ fontWeight: 'bold' }}>
          {this.renderMessage()}
          {' matching '}
          {this.renderSearchTerm()}
          {' selected criteria'}
        </p>
        <div className='results_container' data-testid='results-container'>
          {this.renderAllResults()}
        </div>
      </div>
    )
  }
}
