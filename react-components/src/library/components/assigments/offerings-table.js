import React from 'react'
import { SortableContainer, SortableElement } from 'react-sortable-hoc'
import OfferingRow from './offering-row'
import shouldCancelSorting from '../../helpers/should-cancel-sorting'

import css from './style.scss'

const SortableOffering = SortableElement(OfferingRow)

const SortableOfferings = SortableContainer(({ offerings, offeringDetails, onOfferingUpdate, requestOfferingDetails, clazz }) => {
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
          <SortableOffering key={offering.id} index={idx} offering={offering} offeringDetails={offeringDetails[offering.id]} clazz={clazz}
            requestOfferingDetails={requestOfferingDetails} onOfferingUpdate={onOfferingUpdate} />)
      }
    </div>
  )
})

export default class OfferingsTable extends React.Component {
  render () {
    const shouldCancelStart = shouldCancelSorting([ css.sortIcon, css.activityNameCell ])

    const { offerings, offeringDetails, onOfferingsReorder, onOfferingUpdate, requestOfferingDetails, clazz } = this.props
    if (offerings.length === 0) {
      return <div className={css.noMaterials}>No materials have been assigned to this class.</div>
    }
    return (
      <SortableOfferings offerings={offerings} offeringDetails={offeringDetails} clazz={clazz} onSortEnd={onOfferingsReorder}
        shouldCancelStart={shouldCancelStart} distance={3}
        onOfferingUpdate={onOfferingUpdate} requestOfferingDetails={requestOfferingDetails} />
    )
  }
}
