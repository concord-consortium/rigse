import React from "react";

import StemFinderResult from "./stem-finder-result";
import sortByName from "../helpers/sort-by-name";
import sortResources from "../helpers/sort-resources";
import fadeIn from "../helpers/fade-in";
import pluralize from "../helpers/pluralize";
import waitForAutoShowingLightboxToClose from "../helpers/wait-for-auto-lightbox-to-close";
import filters from "../helpers/filters";
import portalObjectHelpers from "../helpers/portal-object-helpers";
import AutoSuggest from "./search/auto-suggest";
import FeaturedCollections from "./featured-collections/featured-collections";
import Collections from "./collections";

import css from "./stem-finder.scss";

const DISPLAY_LIMIT_INCREMENT = 6;

interface SubjectArea {
  key: string;
  title: string;
  searchAreas: string[]
}

interface GradeLevel {
  key: string;
  title: string;
  grades: string[];
  label: string;
  searchGroups: string[];
}

interface Props {
  hideFeatured?: boolean;
  subjectAreaKey?: string;
  gradeLevelKey?: string;
  sortOrder?: string;
}

interface State {
  collections: any[],
  displayLimit: number,
  featuredCollections: any[],
  firstSearch: boolean,
  gradeLevelsSelected: GradeLevel[],
  gradeLevelsSelectedMap: Record<string, GradeLevel|undefined>,
  hideFeatured: boolean,
  includeOfficial: boolean,
  includeContributed: boolean,
  includeMine: boolean,
  initPage: boolean,
  isSmallScreen: boolean,
  keyword: string,
  lastSearchResultCount: number,
  noResourcesFound: boolean,
  numTotalResources: number,
  numTotalCollections: number;
  opacity: number,
  resources: any[],
  searching: boolean,
  searchInput: string,
  searchPage: number,
  sortOrder: string,
  subjectAreasSelected: SubjectArea[],
  subjectAreasSelectedMap: Record<string, SubjectArea|undefined>,
  usersAuthoredResourcesCount: number
}

class StemFinder extends React.Component<Props, State> {

  constructor(props: Props) {
    super(props);

    const hideFeatured = this.props.hideFeatured || false;
    let subjectAreaKey = this.props.subjectAreaKey;
    let gradeLevelKey = this.props.gradeLevelKey;
    const sortOrder = this.props.sortOrder || "";

    if (!subjectAreaKey && !gradeLevelKey) {
      //
      // If we are not passed props indicating filters to pre-populate
      // then attempt to see if this information is available in the URL.
      //
      const params = this.getFiltersFromURL();
      subjectAreaKey = params.subject;
      gradeLevelKey = params["grade-level"];

      subjectAreaKey = this.mapSubjectArea(subjectAreaKey);
    }

    //
    // Scroll to stem finder if we have filters specified.
    //
    if (subjectAreaKey || gradeLevelKey) {
      // this.scrollToFinder()
    }

    const subjectAreasSelected = [];
    const subjectAreasSelectedMap: any = {};
    let i;

    if (subjectAreaKey) {
      const subjectAreas = filters.subjectAreas;
      for (i = 0; i < subjectAreas.length; i++) {
        const subjectArea = subjectAreas[i];
        if (subjectArea.key === subjectAreaKey) {
          subjectAreasSelected.push(subjectArea);
          subjectAreasSelectedMap[subjectArea.key] = subjectArea;
        }
      }
    }

    const gradeLevelsSelected = [];
    const gradeLevelsSelectedMap: any = {};

    if (gradeLevelKey) {
      const gradeLevels = filters.gradeLevels;
      for (i = 0; i < gradeLevels.length; i++) {
        const gradeLevel = gradeLevels[i];
        if (gradeLevel.key === gradeLevelKey) {
          gradeLevelsSelected.push(gradeLevel);
          gradeLevelsSelectedMap[gradeLevel.key] = gradeLevel;
        }
      }
    }

    this.state = {
      collections: [],
      displayLimit: DISPLAY_LIMIT_INCREMENT,
      featuredCollections: [],
      firstSearch: true,
      gradeLevelsSelected,
      gradeLevelsSelectedMap,
      hideFeatured,
      includeOfficial: true,
      includeContributed: false,
      includeMine: false,
      initPage: true,
      isSmallScreen: window.innerWidth <= 768,
      keyword: "",
      lastSearchResultCount: 0,
      noResourcesFound: false,
      numTotalResources: 0,
      numTotalCollections: 0,
      opacity: 1,
      resources: [],
      searching: false,
      searchInput: "",
      searchPage: 1,
      sortOrder,
      subjectAreasSelected,
      subjectAreasSelectedMap,
      usersAuthoredResourcesCount: 0
    };
  }

  //
  // If the current URL is formatted to include stem finder filters,
  // return the filters specified in the URL as filter-name => filter-value
  // pairs.
  //
  getFiltersFromURL () {
    const ret: any = {};

    let path = window.location.pathname;
    if (!path.startsWith("/")) { path = "/" + path; }

    const parts = path.split("/");

    if (parts.length >= 4 && parts[1] === "resources") {
      ret[parts[2]] = parts[3];
    }

    return ret;
  }

  mapSubjectArea (subjectArea: any) {
    switch (subjectArea) {
      case "biology":
      case "life-science":
        return "life-sciences";
      case "engineering":
        return "engineering-tech";
    }
    return subjectArea;
  }

  UNSAFE_componentWillMount () {
    waitForAutoShowingLightboxToClose(() => {
      this.search();
    });
  }

  handlePageScroll = (event: any) => {
    const scrollTop = document.documentElement.scrollTop || document.body.scrollTop;
    if (
      scrollTop > window.innerHeight / 2 &&
      !this.state.searching &&
      this.state.resources.length !== 0 &&
      !(this.state.displayLimit >= this.state.numTotalResources)
    ) {
      this.search(true);
    }
  };

  handleLightboxScroll = (event: any) => {
    const scrollTop = event.srcElement.scrollTop;
    if (
      scrollTop > window.innerHeight / 3 &&
      !this.state.searching &&
      this.state.resources.length !== 0 &&
      !(this.state.displayLimit >= this.state.numTotalResources)
    ) {
      this.search(true);
    }
  };

  componentDidMount () {
    if (document.getElementById("pprfl")) {
      document.getElementById("pprfl")?.addEventListener("scroll", this.handleLightboxScroll);
    } else {
      document.addEventListener("scroll", this.handlePageScroll);
    }

    window.addEventListener("resize", () => {
      this.setState({ isSmallScreen: window.innerWidth <= 768 });
    });
  }

  componentWillUnmount () {
    if (document.getElementById("pprfl")) {
      document.getElementById("pprfl")?.removeEventListener("scroll", this.handleLightboxScroll);
    } else {
      document.removeEventListener("scroll", this.handlePageScroll);
    }
  }

  getQueryParams = (incremental: any, keyword: any) => {
    const searchPage = incremental ? this.state.searchPage + 1 : 1;
    let query = keyword !== undefined ? ["search_term=", encodeURIComponent(keyword)] : [];
    query = query.concat([
      "&skip_lightbox_reloads=true",
      "&sort_order=Alphabetical",
      "&model_types=All",
      "&include_related=0",
      "&investigation_page=",
      String(searchPage),
      "&activity_page=",
      String(searchPage),
      "&interactive_page=",
      String(searchPage),
      "&collection_page=",
      String(searchPage),
      "&per_page=",
      String(DISPLAY_LIMIT_INCREMENT)
    ]);

    // subject areas
    this.state.subjectAreasSelected.forEach((subjectArea: any) => {
      subjectArea.searchAreas.forEach((searchArea: any) => {
        query.push("&subject_areas[]=");
        query.push(encodeURIComponent(searchArea));
      });
    });

    // grade
    this.state.gradeLevelsSelected.forEach((gradeFilter: any) => {
      if (gradeFilter.searchGroups) {
        gradeFilter.searchGroups.forEach((searchGroup: any) => {
          query.push("&grade_level_groups[]=");
          query.push(encodeURIComponent(searchGroup));
        });
      }
      // TODO: informal learning?
    });

    let includedResources = this.state.includeMine ? "&include_mine=1" : "";
    includedResources += this.state.includeOfficial ? "&include_official=1" : "";
    includedResources += this.state.includeContributed ? "&include_contributed=1" : "";
    query.push(includedResources);

    return query.join("");
  };

  search (incremental?: any) {
    /* eslint-disable react/no-access-state-in-setstate */
    const displayLimit = incremental ? this.state.displayLimit + DISPLAY_LIMIT_INCREMENT : DISPLAY_LIMIT_INCREMENT;
    const featuredCollections = incremental ? this.state.featuredCollections.slice(0) : [];
    let resources = incremental ? this.state.resources.slice(0) : [];
    const searchPage = incremental ? this.state.searchPage + 1 : 1;
    const keyword = jQuery.trim(this.state.searchInput);
    const collections: any[] = [];
    /* eslint-enable react/no-access-state-in-setstate */

    // short circuit further incremental searches when all data has been downloaded
    if (incremental && (this.state.lastSearchResultCount === 0)) {
      this.setState({
        displayLimit
      });
      return;
    }

    if (keyword !== "") {
      gtag("event", "search", {
        "category": "Home Page Search",
        "label": keyword
      });
    }

    this.setState({
      keyword,
      searching: true,
      noResourcesFound: false,
      featuredCollections,
      resources
    });

    jQuery.ajax({
      url: Portal.API_V1.SEARCH,
      data: this.getQueryParams(incremental, keyword),
      dataType: "json"
    }).done((result1: any) => {
      let numTotalResources = 0;
      let numTotalCollections = 0;
      const results = result1.results;
      const usersAuthoredResourcesCount = result1.filters.number_authored_resources;
      let lastSearchResultCount = 0;

      results.forEach((result: any) => {
        result.materials.forEach((material: any) => {
          portalObjectHelpers.processResource(material);
          if (material.material_type === "Collection") {
            featuredCollections.push(material);
            // only set collections on initial search
            if (!incremental) {
              collections.push(material);
            }
          } else {
            resources.push(material);
            lastSearchResultCount++;
          }
        });
        if (result.type === "collections") {
          numTotalCollections = collections.length;
        } else {
          numTotalResources += result.pagination.total_items;
        }
      });

      if (featuredCollections.length > 1) {
        featuredCollections.sort(sortByName);
      }
      resources = sortResources(resources, this.state.sortOrder);

      if (this.state.firstSearch) {
        fadeIn(this);
      }

      this.setState({
        firstSearch: false,
        featuredCollections,
        collections,
        resources,
        numTotalResources,
        numTotalCollections,
        searchPage,
        displayLimit,
        searching: false,
        noResourcesFound: numTotalResources === 0,
        lastSearchResultCount,
        usersAuthoredResourcesCount
      });

      this.showResources();
    });
  }

  buildFilterId (filterKey: any) {
    const filterKeyWords = filterKey.split("-");
    const filterId = filterKeyWords.length > 1
      ? filterKeyWords[0] + filterKeyWords[1].charAt(0).toUpperCase() + filterKeyWords[1].slice(1)
      : filterKeyWords[0];
    return filterId;
  }

  scrollToFinder () {
    if (document.getElementById("finderLightbox")) {
      document.getElementById("finderLightbox")?.scrollIntoView({ behavior: "smooth", block: "start", inline: "nearest" });
    }
  }

  noOptionsSelected () {
    if (
      this.state.subjectAreasSelected.length === 0 &&
      this.state.gradeLevelsSelected.length === 0
    ) {
      return true;
    } else {
      return false;
    }
  }

  renderLogo (subjectArea: any) {
    const filterId = this.buildFilterId(subjectArea.key);
    const selected = this.state.subjectAreasSelectedMap[subjectArea.key];
    const className = selected ? css.selected : null;

    const clicked = () => {
      this.setState((prev) => {
        const subjectAreasSelected = prev.subjectAreasSelected.slice();
        const subjectAreasSelectedMap = prev.subjectAreasSelectedMap;
        const index = subjectAreasSelected.indexOf(subjectArea);

        if (index === -1) {
          subjectAreasSelectedMap[subjectArea.key] = subjectArea;
          subjectAreasSelected.push(subjectArea);
          jQuery("#" + css[filterId]).addClass(css.selected);
          gtag("event", "click", {
            "category": "Home Page Filter",
            "label": subjectArea.title
          });
        } else {
          subjectAreasSelectedMap[subjectArea.key] = undefined;
          subjectAreasSelected.splice(index, 1);
          jQuery("#" + css[filterId]).removeClass(css.selected);
        }
        this.scrollToFinder();
        return {
          subjectAreasSelected,
          subjectAreasSelectedMap,
          hideFeatured: true,
          initPage: false
        };
      }, this.search);
    };

    return (
      <li key={subjectArea.key} id={css[filterId]} className={className} onClick={clicked}>
        { subjectArea.title }
      </li>
    );
  }

  renderGLLogo (gradeLevel: any) {
    let className = "portal-pages-finder-form-filters-logo";
    const filterId = this.buildFilterId(gradeLevel.key);

    const selected = this.state.gradeLevelsSelectedMap[gradeLevel.key];
    if (selected) {
      className += " " + css.selected;
    }

    const clicked = () => {
      this.setState((prev) => {
        const gradeLevelsSelected = prev.gradeLevelsSelected.slice();
        const gradeLevelsSelectedMap = prev.gradeLevelsSelectedMap;
        const index = gradeLevelsSelected.indexOf(gradeLevel);

        if (index === -1) {
          gradeLevelsSelectedMap[gradeLevel.key] = gradeLevel;
          gradeLevelsSelected.push(gradeLevel);
          jQuery("#" + css[filterId]).addClass(css.selected);
          gtag("event", "click", {
            "category": "Home Page Filter",
            "label": gradeLevel.title
          });
        } else {
          gradeLevelsSelectedMap[gradeLevel.key] = undefined;
          gradeLevelsSelected.splice(index, 1);
          jQuery("#" + css[filterId]).removeClass(css.selected);
        }
        this.scrollToFinder();
        return {
          gradeLevelsSelected,
          gradeLevelsSelectedMap,
          hideFeatured: true,
          initPage: false
        };
      }, this.search);
    };

    return (
      <li key={gradeLevel.key} id={css[filterId]} className={className} onClick={clicked}>
        { gradeLevel.title }
      </li>
    );
  }

  renderSubjectAreas () {
    const containerClassName = this.state.isSmallScreen ? css.finderOptionsContainer : `${css.finderOptionsContainer} ${css.open}`;
    return (
      <div className={containerClassName}>
        <h2 onClick={this.handleFilterHeaderClick}>Subject</h2>
        <ul>
          { filters.subjectAreas.map((subjectArea: any) => {
            return this.renderLogo(subjectArea);
          }) }
        </ul>
      </div>
    );
  }

  renderGradeLevels () {
    const containerClassName = this.state.isSmallScreen ? css.finderOptionsContainer : `${css.finderOptionsContainer} ${css.open}`;
    return (
      <div className={containerClassName}>
        <h2 onClick={this.handleFilterHeaderClick}>Grade Level</h2>
        <ul>
          { filters.gradeFilters.map((gradeLevel: any) => {
            return this.renderGLLogo(gradeLevel);
          }) }
        </ul>
      </div>
    );
  }

  handleOfficialClick = (e: any) => {
    e.currentTarget.classList.toggle(css.selected);
    this.setState((prev) => ({
      hideFeatured: true,
      includeOfficial: !prev.includeOfficial
    }), this.search);
    gtag("event", "click", {
      "category": "Home Page Filter",
      "label": "Official"
    });
  };

  handleCommunityClick = (e: any) => {
    e.currentTarget.classList.toggle(css.selected);
    this.setState((prev) => ({
      hideFeatured: true,
      includeContributed: !prev.includeContributed
    }), this.search);
    gtag("event", "click", {
      "category": "Home Page Filter",
      "label": "Community"
    });
  };

  clearFilters () {
    jQuery(".portal-pages-finder-form-subject-areas-logo").removeClass(css.selected);
    this.setState({
      subjectAreasSelected: [],
      gradeLevelsSelected: [],
      keyword: "",
      searchInput: ""
    }, this.search);
  }

  clearKeyword () {
    this.setState({ keyword: "", searchInput: "" }, () => this.search());
  }

  toggleFilter (type: any, filter: any) {
    this.setState({ initPage: false });
    const selectedKey: ("gradeLevelsSelected"|"subjectAreasSelected") = (type + "Selected") as any;
    const selectedFilters = this.state[selectedKey].slice();
    const index = selectedFilters.indexOf(filter);
    if (index === -1) {
      selectedFilters.push(filter);
      jQuery("#" + filter.key).addClass(css.selected);
      gtag("event", "click", {
        "category": "Home Page Filter",
        "label": filter.title
      });
    } else {
      selectedFilters.splice(index, 1);
      jQuery("#" + filter.key).removeClass(css.selected);
    }
    const state: any = {};
    state[selectedKey] = selectedFilters;
    this.setState(state, this.search);
  }

  handleSearchInputChange = (searchInput: any) => {
    this.setState({ searchInput });
  };

  handleSearchSubmit = (e: any) => {
    e.preventDefault();
    e.stopPropagation();
    this.search();
    this.scrollToFinder();
    this.setState({
      hideFeatured: true,
      initPage: false
    });
  };

  handleAutoSuggestSubmit = (searchInput: any) => {
    this.setState({
      hideFeatured: true,
      initPage: false
    });
    this.setState({ searchInput }, () => {
      this.search();
      this.scrollToFinder();
    });
  };

  handleSortSelection = (e: any) => {
    e.preventDefault();
    e.stopPropagation();
    this.setState({
      hideFeatured: true,
      initPage: false
    });
    this.setState({ sortOrder: e.target.value }, () => {
      this.search();
    });

    gtag("event", "selection", {
      "category": "Finder Sort",
      "label": e.target.value
    });
  };

  renderSearch () {
    const containerClassName = this.state.isSmallScreen ? css.finderOptionsContainer : `${css.finderOptionsContainer} ${css.open}`;
    return (
      <div className={containerClassName}>
        <h2 onClick={this.handleFilterHeaderClick}>Keywords</h2>
        <form onSubmit={this.handleSearchSubmit}>
          <div className={"portal-pages-search-input-container"}>
            <AutoSuggest
              name={"search-terms"}
              query={this.state.searchInput}
              getQueryParams={this.getQueryParams}
              onChange={this.handleSearchInputChange}
              onSubmit={this.handleAutoSuggestSubmit}
              placeholder={"Type search term here"}
              skipAutoSearch
            />
          </div>
        </form>
      </div>
    );
  }

  isAdvancedUser () {
    const isAdvancedUser = Portal.currentUser.isAdmin || Portal.currentUser.isAuthor || Portal.currentUser.isManager || Portal.currentUser.isResearcher;
    return (isAdvancedUser);
  }

  renderAdvanced () {
    return (
      <>
        <div className={css.finderOptionsContainer}>
          <h2 onClick={this.handleFilterHeaderClick}>Advanced</h2>
          <ul>
            <li id={css.official} className={css.selected} onClick={(e) => this.handleOfficialClick(e)}>Official</li>
            <li id={css.community} onClick={(e) => this.handleCommunityClick(e)}>Community</li>
          </ul>
        </div>
        <div className={css.advancedSearchLink}>
          <a href="/search" title="Advanced Search">Advanced Search</a>
        </div>
      </>
    );
  }

  renderForm () {
    const isAdvancedUser = this.isAdvancedUser();
    return (
      <div className={"col-3 " + css.finderForm}>
        <div className={"portal-pages-finder-form-inner"} style={{ opacity: this.state.opacity }}>
          { this.renderSearch() }
          { this.renderSubjectAreas() }
          { this.renderGradeLevels() }
          { isAdvancedUser && this.renderAdvanced() }
        </div>
      </div>
    );
  }

  handleFilterHeaderClick = (e: any) => {
    e.currentTarget.parentElement.classList.toggle(css.open);
  };

  handleShowOnlyMine = (e: any) => {
    this.setState((prev) => ({ includeMine: !prev.includeMine }), this.search);
  };

  renderShowOnly () {
    const { includeMine } = this.state;
    return (
      <div className={css.showOnly}>
        <label htmlFor="includeMine"><input type="checkbox" name="includeMine" value="true" id="includeMine" onChange={this.handleShowOnlyMine} defaultChecked={includeMine} /> Show only resources I authored</label>
      </div>
    );
  }

  renderSortMenu () {
    const sortValues = ["Alphabetical", "Newest", "Oldest"];

    return (
      <div className={css.sortMenu}>
        <label htmlFor="sort">Sort by</label>
        <select name="sort" value={this.state.sortOrder} onChange={this.handleSortSelection}>
          { sortValues.map((sortValue, index) => {
            return <option key={`${sortValue}-${index}`} value={sortValue}>{ sortValue }</option>;
          }) }
        </select>
      </div>
    );
  }

  renderResultsHeader () {
    const { displayLimit, noResourcesFound, numTotalResources, searching, usersAuthoredResourcesCount } = this.state;
    const finderHeaderClass = this.isAdvancedUser() || usersAuthoredResourcesCount > 0 ? `${css.finderHeader} ${css.advanced}` : css.finderHeader;

    if (noResourcesFound || searching) {
      return (
        <div className={finderHeaderClass}>
          <h2>Activities</h2>
          <div className={css.finderHeaderWrapper}>
            <div className={css.finderHeaderLeft}>
              <div className={css.finderHeaderResourceCount}>
                { noResourcesFound ? "No Resources Found" : "Loading..." }
              </div>
              { (this.isAdvancedUser() || usersAuthoredResourcesCount > 0) && this.renderShowOnly() }
            </div>
            { this.renderSortMenu() }
          </div>
        </div>
      );
    }

    const showingAll = displayLimit >= numTotalResources;
    const multipleResources = numTotalResources > 1;
    const resourceCount = showingAll ? numTotalResources : displayLimit + " of " + numTotalResources;
    jQuery("#portal-pages-finder").removeClass("loading");
    return (
      <div className={finderHeaderClass}>
        <h2>Activities</h2>
        <div className={css.finderHeaderWrapper}>
          <div className={css.finderHeaderLeft}>
            <div className={css.finderHeaderResourceCount}>
              { showingAll && multipleResources ? "Showing All " : "Showing " }
              <strong>
                { resourceCount + " " + pluralize(resourceCount, "Activity", "Activities") }
              </strong>
            </div>
            { (this.isAdvancedUser() || usersAuthoredResourcesCount > 0) && this.renderShowOnly() }
          </div>
          { this.renderSortMenu() }
        </div>
      </div>
    );
  }

  renderLoadMore () {
    if ((this.state.resources.length === 0) || (this.state.displayLimit >= this.state.numTotalResources)) {
      return null;
    }
  }

  showResources () {
    setTimeout(() => {
      const resourceItems = document.querySelectorAll(".resourceItem");
      resourceItems.forEach((resourceItem) => { (resourceItem as HTMLElement).style.opacity = "1"; });
    }, 500);
  }

  renderCollections () {
    const { collections, searchInput, numTotalCollections, initPage, hideFeatured, keyword } = this.state;
    const validSearchInput = keyword.length > 0 && (searchInput.trim() === keyword);
    const showCollections = !initPage && (validSearchInput || !this.noOptionsSelected()) && collections.length > 0;

    if (showCollections) {
      return <Collections collections={collections} numTotalCollections={numTotalCollections} />;
    }

    let featuredCollections = this.state.featuredCollections;
    featuredCollections = featuredCollections.sort(() => Math.random() - Math.random()).slice(0, 3);
    const showFeaturedCollections = !hideFeatured && initPage && this.noOptionsSelected() && featuredCollections.length > 0;

    if (showFeaturedCollections) {
      return <FeaturedCollections featuredCollections={featuredCollections} />;
    }

    return null;
  }

  renderResults () {
    if (this.state.firstSearch) {
      return (
        <div className={css.loading}>
          Loading
        </div>
      );
    }

    const resources = this.state.resources.slice(0, this.state.displayLimit);
    return (
      <>
        { this.renderCollections() }
        { this.renderResultsHeader() }
        <div className={css.finderResultsContainer}>
          { resources.map((resource: any, index: any) => {
            return <StemFinderResult key={`${resource.external_url}-${index}`} resource={resource} index={index} showResources={this.showResources} />;
          }) }
        </div>
        { this.state.searching ? <div className={css.loading}>Loading</div> : null }
        { this.renderLoadMore() }
      </>
    );
  }

  render () {
    return (
      <div className={"cols " + css.finderWrapper}>
        { this.renderForm() }
        <div id={css.finderResults} className="portal-pages-finder-results col-9" style={{ opacity: this.state.opacity }}>
          { this.renderResults() }
        </div>
      </div>
    );
  }
}

export default StemFinder;
