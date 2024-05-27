import React, { createRef } from 'react'

export default class SPagination extends React.Component<any, any> {
  // @ts-expect-error TS(2554): Expected 0 arguments, but got 1.
  divRef = createRef(null)

  componentDidMount () {
    if (this.props.info.total_pages < 2) {
      // don't display pagination if there's only 1 page
      return
    }

    // @ts-expect-error TS(2769): No overload matches this call.
    const node = jQuery(this.divRef.current)
    // @ts-expect-error TS(2339): Property 'paging' does not exist on type 'JQuerySt... Remove this comment to see the full error message
    node.paging(this.props.info.total_items, {
      format: '<  . (qq -) nnncnnn (- pp) >',
      perpage: this.props.info.per_page,
      lapping: 0,
      page: this.props.info.current_page,
      onSelect: this.props.onSelect,
      onFormat (type: any) {
        switch (type) {
          case 'block':
            if (!this.active) {
              return `<span class='disabled'>${this.value}</span>`
            } else if (this.value !== this.page) {
              return `<em><a href='#' class='page'>${this.value}</a></em>`
            }
            return `<span class='current page'>${this.value}</span>`

          case 'next':
            if (this.active) {
              return "<a href='#' class='next'>Next →</a>"
            }
            return '<span class="disabled">Next →</span>'

          case 'prev':
            if (this.active) {
              return "<a href='#' class='prev'>← Previous</a>"
            }
            return '<span class="disabled">← Previous</span>'

          case 'first':
            if (this.active) {
              return "<a href='#' class='first'>|&lt;</a>"
            }
            return '<span class="disabled">|&lt;</span>'

          case 'last':
            if (this.active) {
              return "<a href='#' class='last'>&gt;|</a>"
            }
            return '<span class="disabled">&gt;|</span>'

          case 'leap':
            if (this.active) { return '   ' } else { return '' }
          case 'fill':
            if (this.active) { return '...' } else { return '' }
          default:
            return ''
        }
      }
    })
  }

  shouldComponentUpdate () {
    return false
  }

  render () {
    // @ts-expect-error TS(2322): Type 'RefObject<unknown>' is not assignable to typ... Remove this comment to see the full error message
    return <div ref={this.divRef} className='pagination' />
  }
}
