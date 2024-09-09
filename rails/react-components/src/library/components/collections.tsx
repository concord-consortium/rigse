import React from "react";
import StemFinderResult from "./stem-finder-result";
import pluralize from "../helpers/pluralize";

import css from "./collections.scss";

interface Props {
  collections: any[]
  numTotalCollections: number;
  searching: boolean;
  showAllCollections: boolean;
  enableShowAllCollections: () => void;
}

const initialDisplayCount = 2;

export default class Collections extends React.Component<Props> {

  render () {
    const { collections, numTotalCollections, searching, showAllCollections, enableShowAllCollections } = this.props;
    const displayCount = showAllCollections ? numTotalCollections : initialDisplayCount;
    const showingAll = showAllCollections || displayCount >= numTotalCollections;
    const collectionCount = showingAll ? numTotalCollections : displayCount + " of " + numTotalCollections;
    const displayCollections = collections.slice(0, displayCount);

    return (
      <div className={css.finderResultsCollections}>
        <div className={css.finderResultsCollectionsHeader}>
          <h2>Collections</h2>
          <div className={css.finderResultsCollectionsCount}>
            <div>
              {searching ? "Loading..." : <>Showing <strong>{ collectionCount + " " + pluralize(collectionCount, "Collection", "Collections") }</strong> matching your search</>}
            </div>
          </div>
        </div>
        {!searching &&
        <div className={css.finderResultsContainer}>
          { displayCollections.map((collection: any, index: any) => {
            return <StemFinderResult key={`${collection.external_url}-${index}`} resource={collection} index={index} opacity={1} />;
          }) }
        </div>
        }
        {!searching && !showingAll && <div className={css.findResultsCollectionsShowMore}><button onClick={() => enableShowAllCollections()}>Show More</button></div>}
      </div>
    );
  }
}
