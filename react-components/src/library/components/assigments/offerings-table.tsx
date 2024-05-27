import React from 'react'
import OfferingRow from './offering-row'
import { SortableContainer, SortableItem } from '../shared/sortable-helpers'
import css from './style.scss'

const Offerings = ({
  readOnly,
  offerings,
  offeringDetails,
  onOfferingUpdate,
  requestOfferingDetails,
  clazz
}: any) => {
  return (
    <div className={`${css.offeringsTable} ${readOnly ? css.readOnly : ''}`}>
      <div className={css.headers}>
        <span className={css.activityNameCell}>Name</span>
        {/* Empty icon cell just to make sure that total width is correct */}
        <span className={css.iconCell} />
        <span className={css.checkboxCell}>Active</span>
        <span className={css.checkboxCell}>Locked</span>
        <span className={css.detailsCell} />
      </div>
      {
        offerings.map((offering: any, idx: any) =>
          <SortableItem key={offering.id} id={offering.id} className={css.sortableItem} disabled={readOnly}>
            <OfferingRow
              index={idx}
              offering={offering}
              offeringDetails={offeringDetails[offering.id]}
              clazz={clazz}
              requestOfferingDetails={requestOfferingDetails}
              onOfferingUpdate={onOfferingUpdate} readOnly={readOnly}
            />
          </SortableItem>
        )
      }
    </div>
  );
}

const OfferingsTable = (props: any) => {
  const { offerings, offeringDetails, onOfferingsReorder, onOfferingUpdate, requestOfferingDetails, clazz, readOnly } = props

  if (offerings.length === 0) {
    return <div className={css.noMaterials}>No materials have been assigned to this class.</div>
  }

  const renderDragPreview = (itemId: any) => {
    const offering = offerings.find((offering: any) => offering.id === itemId)
    return (
      <OfferingRow
        offering={offering}
        offeringDetails={offeringDetails[offering.id]}
        clazz={clazz}
        requestOfferingDetails={requestOfferingDetails}
        onOfferingUpdate={onOfferingUpdate} readOnly={readOnly}
      />
    )
  }

  return (
    <SortableContainer
      items={offerings.map((offering: any) => offering.id)}
      renderDragPreview={renderDragPreview}
      onReorder={onOfferingsReorder}
    >
      <Offerings
        offerings={offerings}
        offeringDetails={offeringDetails}
        clazz={clazz}
        readOnly={readOnly}
        onOfferingUpdate={onOfferingUpdate}
        requestOfferingDetails={requestOfferingDetails}
      />
    </SortableContainer>
  );
}

export default OfferingsTable
