import React from 'react'
import { SortableContainer, SortableElement } from 'react-sortable-hoc'
import OfferingRow from './offering-row'

import css from './style.scss'

// These elements can be used to sort offering.
const sortableHandles = [ css.sortIcon, css.activityNameCell ]

const shouldCancelSorting = e => {
  // Only HTML elements with selected classes can be used to reorder offerings.
  const classList = e.target.classList
  for (let cl of sortableHandles) {
    if (classList.contains(cl)) {
      return false
    }
  }
  return true
}

const SortableOffering = SortableElement(OfferingRow)

const SortableOfferings = SortableContainer(({ offerings, offeringDetails, onOfferingUpdate, requestOfferingDetails }) => {
  return (
    <div className={css.offeringsTable}>
      <div className={css.headers}>
        <span className={css.activityNameCell}>Name</span>
        {/* Empty icon cell just to make sure that total width is correct */}
        <span className={css.iconCell} />
        <span className={css.checkboxCell}>Active</span>
        <span className={css.checkboxCell}>Locked</span>
        <span className={css.detailsCell} />
      </div>
      {
        offerings.map((offering, idx) =>
          <SortableOffering key={offering.id} index={idx} offering={offering} offeringDetails={offeringDetails[offering.id]}
            requestOfferingDetails={requestOfferingDetails} onOfferingUpdate={onOfferingUpdate} />)
      }
    </div>
  )
})

export default class OfferingsTable extends React.Component {
  render () {
    const { offerings, offeringDetails, onOfferingsReorder, onOfferingUpdate, requestOfferingDetails } = this.props
    if (offerings.length === 0) {
      return <div className={css.noMaterials}>No materials have been assigned to this class.</div>
    }
    return (
      <SortableOfferings offerings={offerings} offeringDetails={offeringDetails} onSortEnd={onOfferingsReorder}
        shouldCancelStart={shouldCancelSorting} distance={3}
        onOfferingUpdate={onOfferingUpdate} requestOfferingDetails={requestOfferingDetails} />
    )
  }
}
