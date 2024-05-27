import React from 'react'

import MBMaterialsCategory from './materials-category'
import MBCollections from './collections'
import MBOwnMaterials from './own-materials'
import MBMaterialsByAuthor from './materials-by-author'

export default class MaterialsBin extends React.Component<any, any> {
  _isSlugTaken: any;
  constructor (props: any) {
    super(props)

    // it is usually very bad form in React to modify props but we will look the other way this time
    // otherwise we need to clone the array just to add the slug
    // @ts-expect-error TS(7023): 'addSlugs' implicitly has return type 'any' becaus... Remove this comment to see the full error message
    var addSlugs = (list: any) => {
      // @ts-expect-error TS(7024): Function implicitly has return type 'any' because ... Remove this comment to see the full error message
      return (() => {
        const result = []
        for (let item of Array.from(list)) {
          // @ts-expect-error TS(2571): Object is of type 'unknown'.
          if (item.category) {
            // @ts-expect-error TS(2571): Object is of type 'unknown'.
            item.slug = this.generateSlug(item.category)
            // @ts-expect-error TS(2571): Object is of type 'unknown'.
            if (item.children) {
              // @ts-expect-error TS(2571): Object is of type 'unknown'.
              result.push(addSlugs(item.children))
            } else {
              result.push(undefined)
            }
          } else {
            result.push(undefined)
          }
        }
        return result
      })()
    }
    addSlugs(this.props.materials)

    // selectedSlugs[X] returns a slug that is selected in column X (or falsy value if nothing is selected).
    // E.g. selectedSlugs = ['category-a', 'subcategory-b', 'category-c'] means that:
    // - 'category-a' is selected in the first column,
    // - 'category-b' is selected in the second column,
    // - 'category-c' is selected in the third column.
    this.state = { selectedSlugs: this.selectFirstSlugs() }

    this.checkHash = this.checkHash.bind(this)
    this.handleCellClick = this.handleCellClick.bind(this)
  }

  // eslint-disable-next-line
  UNSAFE_componentWillMount () {
    // check the hash at startup and for each change
    jQuery(window).on('hashchange', this.checkHash)
    this.checkHash()
  }

  componentWillUnmount () {
    jQuery(window).off('hashchange', this.checkHash)
  }

  selectFirstSlugs () {
    const selectedSlugs = []
    let list = this.props.materials
    while (list && list[0] && list[0].slug) {
      selectedSlugs.push(list[0].slug)
      list = list[0].children
    }
    return selectedSlugs
  }

  checkHash () {
    const hash = jQuery.trim(window.location.hash.substr(1))
    const selectedSlugs = hash.length > 0 ? (hash.split('|')) : this.selectFirstSlugs()
    this.setState({ selectedSlugs })
  }

  handleCellClick (column: any, slug: any) {
    // Unselect all the cells that are to the right of modified column.
    const newSlugs = this.state.selectedSlugs.slice(0, column + 1)
    // Select clicked slug
    newSlugs[column] = slug
    window.location.hash = newSlugs.join('|')
  }

  isSlugSelected (column: any, slug: any) {
    return this.state.selectedSlugs[column] === slug
  }

  generateSlug (name: any) {
    if (this._isSlugTaken == null) {
      this._isSlugTaken = {}
    }
    let slug = name.toLowerCase().replace(/\W/g, '-')
    while (this._isSlugTaken[slug]) {
      slug += '-'
    }
    this._isSlugTaken[slug] = true
    return slug
  }

  // Transforms @props.materials hash into array of arrays representing columns and their rows.
  // Raw form of @props.materials doesn't work well with table view.
  // Also, apply current state (selected cells and visibility).
  _getColumns () {
    const columns: any = []
    // Adds all elements of `array` to column `columnIdx` and marks them as `visible`.
    // Note that the array is @params.materials at the beginning and then its child elements recursively.
    var fillColumns = (array: any, columnIdx: any, visible: any) => {
      if (columnIdx == null) {
        columnIdx = 0
      }
      if (visible == null) {
        visible = true
      }
      if (columns[columnIdx] == null) {
        columns[columnIdx] = []
      }
      array.forEach((cellDef: any) => {
        const selected = this.isSlugSelected(columnIdx, cellDef.slug)
        const rowIdx = columns[columnIdx].length
        columns[columnIdx].push((() => {
          if (cellDef.category) {
            return (
              <MBMaterialsCategory
                key={rowIdx}
                visible={visible}
                selected={selected}
                column={columnIdx}
                slug={cellDef.slug}
                customClass={cellDef.className}
                loginRequired={cellDef.loginRequired}
                handleClick={this.handleCellClick}
                assignToSpecificClass={this.props.assignToSpecificClass}
              >
                {cellDef.category}
              </MBMaterialsCategory>
            )
          } else if (cellDef.collections) {
            return <MBCollections
              key={rowIdx}
              visible={visible}
              collections={cellDef.collections}
              assignToSpecificClass={this.props.assignToSpecificClass}
            />
          } else if (cellDef.ownMaterials) {
            return <MBOwnMaterials key={rowIdx} visible={visible} assignToSpecificClass={this.props.assignToSpecificClass} />
          } else if (cellDef.materialsByAuthor) {
            return <MBMaterialsByAuthor key={rowIdx} visible={visible} assignToSpecificClass={this.props.assignToSpecificClass} />
          }
        })())
        if (cellDef.children) {
          // Recursively go to children array, add its elements to column + 1
          // and mark them visible only if current cell is selected.
          fillColumns(cellDef.children, columnIdx + 1, selected)
        }
      })
    }

    // @ts-expect-error TS(2554): Expected 3 arguments, but got 1.
    fillColumns(this.props.materials)
    return columns
  }

  render () {
    return (
      <div className='materials-bin'>
        // @ts-expect-error TS(7006): Parameter 'column' implicitly has an 'any' type.
        {this._getColumns().map((column: any, idx: number) => <div key={idx} className='mb-column'>{column}</div>)}
      </div>
    )
  }
}
