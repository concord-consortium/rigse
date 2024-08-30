import React from "react";
import StemFinderResult from "./stem-finder-result";
import pluralize from "../helpers/pluralize";

import css from "./collections.scss";

interface Props {
  collections: any[]
  numTotalCollections: number;
}

interface State {
  showAll: boolean;
}

const initialDisplayCount = 2;

export default class Collections extends React.Component<Props, State> {
  constructor (props: Props) {
    super(props);

    this.state = {
      showAll: false
    };
  }

  handleShowMore = () => {
    this.setState({showAll: true});
  };

  render () {
    const { showAll } = this.state;
    const { collections, numTotalCollections } = this.props;
    const displayCount = showAll ? numTotalCollections : initialDisplayCount;
    const showingAll = showAll || displayCount >= numTotalCollections;
    const collectionCount = showingAll ? numTotalCollections : displayCount + " of " + numTotalCollections;
    const displayCollections = collections.slice(0, displayCount);

    return (
      <div className={css.finderResultsCollections}>
        <div className={css.finderResultsCollectionsHeader}>
          <h2>Collections</h2>
          <div className={css.finderResultsCollectionsCount}>
            <div>
              Showing <strong>{ collectionCount + " " + pluralize(collectionCount, "Collection", "Collections") }</strong> matching your search
            </div>
          </div>
        </div>
        <div className={css.finderResultsContainer}>
          { displayCollections.map((collection: any, index: any) => {
            return <StemFinderResult key={`${collection.external_url}-${index}`} resource={collection} index={index} opacity={1} />;
          }) }
        </div>
        {!showingAll && <div className={css.findResultsCollectionsShowMore}><button onClick={this.handleShowMore}>Show More</button></div>}
      </div>
    );
  }
}
