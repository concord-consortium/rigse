import React from 'react'
import OfferingDetails from './offering-details'

import css from './style.scss'

export default class OfferingRow extends React.Component<any, any> {
  onActiveUpdate: any;
  onLockedUpdate: any;
  constructor (props: any) {
    super(props)
    this.state = {
      detailsVisible: false
    }
    this.onActiveUpdate = this.onCheckboxUpdate.bind(this, 'active')
    this.onLockedUpdate = this.onCheckboxUpdate.bind(this, 'locked')
    this.onDetailsToggle = this.onDetailsToggle.bind(this)
  }

  get detailsLabel () {
    const { detailsVisible } = this.state
    return detailsVisible ? '- HIDE DETAIL' : '+ SHOW DETAIL'
  }

  onCheckboxUpdate (name: any, event: any) {
    const { offering, onOfferingUpdate } = this.props
    if (onOfferingUpdate) {
      onOfferingUpdate(offering, name, event.target.checked)
    }
  }

  onDetailsToggle () {
    const { detailsVisible } = this.state
    const { offeringDetails, requestOfferingDetails, offering } = this.props
    const newValue = !detailsVisible
    this.setState({ detailsVisible: newValue })
    if (!offeringDetails) {
      requestOfferingDetails(offering)
    }
  }

  render () {
    const { detailsVisible } = this.state
    const { offering, offeringDetails, clazz, readOnly } = this.props

    return (
      <div className={css.offering}>
        <div>
          { !readOnly && <span className={css.iconCell}><span className={`${css.sortIcon} icon-sort`} /></span> }
          <span className={css.activityNameCell}>{ offering.name }</span>
          <span className={css.checkboxCell}><input type='checkbox' disabled={readOnly} checked={offering.active} onChange={this.onActiveUpdate} /></span>
          <span className={css.checkboxCell}><input type='checkbox' disabled={readOnly} checked={offering.locked} onChange={this.onLockedUpdate} /></span>
          <span className={css.detailsCell}><button className={'textButton adminOption'} onClick={this.onDetailsToggle}>{ this.detailsLabel }</button></span>
        </div>
        {
          detailsVisible && !(offeringDetails || clazz) && <div className={css.loading}>Loading...</div>
        }
        {
          detailsVisible && offeringDetails && clazz && <OfferingDetails offering={offeringDetails} clazz={clazz} />
        }
      </div>
    )
  }
}
