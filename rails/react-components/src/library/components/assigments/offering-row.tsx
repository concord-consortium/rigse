import React from "react";
import OfferingDetails from "./offering-details";

import TriStateCheckbox from "../common/tri-state-checkbox";

import css from "./style.scss";

export default class OfferingRow extends React.Component<any, any> {
  onActiveUpdate: any;
  onLockedUpdate: any;
  constructor (props: any) {
    super(props);
    this.state = {
      detailsVisible: false
    };
    this.onActiveUpdate = this.onCheckboxUpdate.bind(this, "active");
    this.onLockedUpdate = this.onCheckboxUpdate.bind(this, "locked");
    this.onDetailsToggle = this.onDetailsToggle.bind(this);
  }

  get detailsLabel () {
    const { detailsVisible } = this.state;
    return detailsVisible ? "- HIDE DETAIL" : "+ SHOW DETAIL";
  }

  onCheckboxUpdate (name: any, checked: boolean) {
    const { offering, onOfferingUpdate } = this.props;
    if (onOfferingUpdate) {
      onOfferingUpdate(offering, name, checked);
    }
  }

  onDetailsToggle () {
    const { detailsVisible } = this.state;
    const { offeringDetails, requestOfferingDetails, offering } = this.props;
    const newValue = !detailsVisible;
    this.setState({ detailsVisible: newValue });
    if (!offeringDetails) {
      requestOfferingDetails(offering);
    }
  }

  partiallyCheckedMessage (flag: string) {
    const message = [`Some students have different ${flag} settings`];
    if (!this.state.detailsVisible) {
      message.push(`, click "Show Detail" to see which students`);
    }
    message.push(".");
    return message.join("");
  }

  isPartiallyChecked (offering: any, flag: string) {
    const checked = offering[flag];
    const totalCount = offering.metadata.length;
    const numChecked = offering.metadata.reduce((count: number, metadata: any) => count + (metadata[flag] ? 1 : 0), 0);

    if (checked) {
      return numChecked < totalCount;
    }
    return numChecked > 0;
  }

  render () {
    const { detailsVisible } = this.state;
    const { offering, offeringDetails, clazz, readOnly, onSetStudentOfferingMetadata } = this.props;

    const partiallyActive = this.isPartiallyChecked(offering, "active");
    const partiallyLocked = this.isPartiallyChecked(offering, "locked");

    return (
      <div className={css.offering}>
        <div>
          { !readOnly && <span className={css.iconCell}><span className={`${css.sortIcon} icon-sort`} /></span> }
          <span className={css.activityNameCell}>{ offering.name }</span>
          <span className={css.checkboxCell}>
            <TriStateCheckbox
              disabled={readOnly}
              checked={offering.active}
              partiallyChecked={partiallyActive}
              partiallyCheckedMessage={this.partiallyCheckedMessage("visible")}
              onChange={this.onActiveUpdate}
            />
          </span>
          <span className={css.checkboxCell}>
            <TriStateCheckbox
              disabled={readOnly}
              checked={offering.locked}
              partiallyChecked={partiallyLocked}
              partiallyCheckedMessage={this.partiallyCheckedMessage("locked")}
              onChange={this.onLockedUpdate}
            />
          </span>
          <span className={css.detailsCell}><button className={"textButton adminOption"} onClick={this.onDetailsToggle}>{ this.detailsLabel }</button></span>
        </div>
        {
          detailsVisible && !(offeringDetails || clazz) && <div className={css.loading}>Loading...</div>
        }
        {
          detailsVisible && offeringDetails && clazz && <OfferingDetails offeringDetails={offeringDetails} offering={offering} clazz={clazz} onSetStudentOfferingMetadata={onSetStudentOfferingMetadata} />
        }
      </div>
    );
  }
}
