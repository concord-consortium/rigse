import Component from '../helpers/component'

const HeaderFilter = Component({
  handleClear: function () {
    this.props.toggleFilter(this.props.type, this.props.filter)
  },

  render: function () {
    return (
      <div className='portal-pages-finder-header-filter'>
        {this.props.filter.title}
        <span onClick={this.handleClear} />
      </div>
    )
  }
})

export default HeaderFilter
