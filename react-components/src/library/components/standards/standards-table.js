import React from 'react'
import StandardsRow from './standards-row'

export const PAGE_SIZE = 10

export default class StandardsTable extends React.Component {
  constructor (props) {
    super(props)
    this.paginateUp = this.paginateUp.bind(this)
    this.paginateDown = this.paginateDown.bind(this)
  }

  paginateUp () {
    const { start } = this.props
    if ((start + PAGE_SIZE) < this.props.count) {
      window.searchASN(start + PAGE_SIZE)
    }
  }

  paginateDown () {
    const { start } = this.props
    if ((start - PAGE_SIZE) > -1) {
      window.searchASN(start - PAGE_SIZE)
    }
  }

  renderPagination () {
    const { count, start } = this.props

    if (count) {
      let end = (start + PAGE_SIZE)
      if (end > count) {
        end = count
      }

      const showDown = start - PAGE_SIZE > -1
      const showUp = start + PAGE_SIZE < count

      return (
        <tr>
          <td colSpan={5} className='asn_results_pagination_row'>
            {showDown
              ? <a className='asn_results_pagination_arrows' onClick={this.paginateDown}>{'<<'}</a>
              : '<<' }
            Showing {start + 1} - {end} of {count}
            {showUp
              ? <a className='asn_results_pagination_arrows' onClick={this.paginateUp}>{'>>'}</a>
              : '>>' }
          </td>
        </tr>
      )
    }
  }

  render () {
    const { statements, material } = this.props

    return (
      <table className='asn_results_table'>
        <tbody>
          {this.renderPagination()}
          <tr>
            <th className='asn_results_th'>Type</th>
            <th className='asn_results_th'>Description</th>
            <th className='asn_results_th'>Label</th>
            <th className='asn_results_th'>Notation</th>
            <th className='asn_results_th'>URI</th>
            <th className='asn_results_th'>Grades</th>
            <th className='asn_results_th'>Leaf</th>
            <th className='asn_results_th_right'>Action</th>
          </tr>
          {statements.map(statement => <StandardsRow key={statement.uri} statement={statement} material={material} />)}
        </tbody>
      </table>
    )
  }
}
