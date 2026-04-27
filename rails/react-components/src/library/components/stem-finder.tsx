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
import { FilterChip } from "./filter-chip";
import { buildSelectedFilterChips, SelectedFilterChip } from "../helpers/selected-filter-chips";

import css from "./stem-finder.scss";

const DISPLAY_LIMIT_INCREMENT = 6;

const SMALL_SCREEN_MAX_WIDTH = 768;
const SECTION_KEYS = ["keywords", "subject", "grade-level", "resource-type", "advanced"] as const;
type SectionKey = typeof SECTION_KEYS[number];
const defaultSectionsOpen = (open: boolean): Record<SectionKey, boolean> =>
  SECTION_KEYS.reduce((acc, k) => { acc[k] = open; return acc; }, {} as Record<SectionKey, boolean>);

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

interface ResourceType {
  key: string;
  searchMaterialType: string;
  title: string;
}

interface Props {
  hideFeatured?: boolean;
  subjectAreaKey?: string;
  gradeLevelKey?: string;
  resourceTypeKey?: string;
  sortOrder?: string;
}

interface State {
  displayLimit: number,
  featuredCollections: any[],
  firstSearch: boolean,
  gradeLevelsSelected: GradeLevel[],
  gradeLevelsSelectedMap: Record<string, GradeLevel|undefined>,
  includeOfficial: boolean,
  includeContributed: boolean,
  includeMine: boolean,
  initPage: boolean,
  isSmallScreen: boolean,
  sectionsOpen: Record<SectionKey, boolean>,
  keyword: string,
  lastSearchResultCount: number,
  noResourcesFound: boolean,
  numTotalResources: number,
  opacity: number,
  resources: any[],
  searching: boolean,
  searchInput: string,
  searchPage: number,
  sortOrder: string,
  subjectAreasSelected: SubjectArea[],
  subjectAreasSelectedMap: Record<string, SubjectArea|undefined>,
  resourceTypesSelected: ResourceType[],
  resourceTypesSelectedMap: Record<string, ResourceType|undefined>,
  usersAuthoredResourcesCount: number,
}

class StemFinder extends React.Component<Props, State> {

  constructor(props: Props) {
    super(props);

    let subjectAreaKey = this.props.subjectAreaKey;
    let gradeLevelKey = this.props.gradeLevelKey;
    let resourceTypeKey = this.props.resourceTypeKey;
    const sortOrder = this.props.sortOrder || "";

    if (!subjectAreaKey && !gradeLevelKey && !resourceTypeKey) {
      //
      // If we are not passed props indicating filters to pre-populate
      // then attempt to see if this information is available in the URL.
      //
      const params = this.getFiltersFromURL();
      subjectAreaKey = params.subject;
      gradeLevelKey = params["grade-level"];
      resourceTypeKey = params["resource-type"];

      subjectAreaKey = this.mapSubjectArea(subjectAreaKey);
    }

    //
    // Scroll to stem finder if we have filters specified.
    //
    if (subjectAreaKey || gradeLevelKey || resourceTypeKey) {
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

    const resourceTypesSelected: ResourceType[] = [];
    const resourceTypesSelectedMap: Record<string, ResourceType|undefined> = {};

    if (resourceTypeKey) {
      const resourceTypesConfig: ResourceType[] = filters.resourceTypeFilters;
      const match = resourceTypesConfig.find(rt => rt.key === resourceTypeKey);
      if (match) {
        resourceTypesSelected.push(match);
        resourceTypesSelectedMap[match.key] = match;
      }
      // Unknown keys (e.g., /resources/resource-type/foo-unknown) are silently ignored.
    }

    const initialIsSmallScreen = window.innerWidth <= SMALL_SCREEN_MAX_WIDTH;

    this.state = {
      displayLimit: DISPLAY_LIMIT_INCREMENT,
      featuredCollections: [],
      firstSearch: true,
      gradeLevelsSelected,
      gradeLevelsSelectedMap,
      includeOfficial: true,
      includeContributed: false,
      includeMine: false,
      initPage: true,
      isSmallScreen: initialIsSmallScreen,
      sectionsOpen: defaultSectionsOpen(!initialIsSmallScreen),
      keyword: "",
      lastSearchResultCount: 0,
      noResourcesFound: false,
      numTotalResources: 0,
      opacity: 1,
      resources: [],
      searching: false,
      searchInput: "",
      searchPage: 1,
      sortOrder,
      subjectAreasSelected,
      subjectAreasSelectedMap,
      resourceTypesSelected,
      resourceTypesSelectedMap,
      usersAuthoredResourcesCount: 0,
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

  private handleResize = () => {
    const isSmallScreen = window.innerWidth <= SMALL_SCREEN_MAX_WIDTH;
    if (isSmallScreen === this.state.isSmallScreen) return;
    this.setState({
      isSmallScreen,
      sectionsOpen: defaultSectionsOpen(!isSmallScreen)
    });
  };

  componentDidMount () {
    if (document.getElementById("pprfl")) {
      document.getElementById("pprfl")?.addEventListener("scroll", this.handleLightboxScroll);
    } else {
      document.addEventListener("scroll", this.handlePageScroll);
    }

    window.addEventListener("resize", this.handleResize);
  }

  componentWillUnmount () {
    if (document.getElementById("pprfl")) {
      document.getElementById("pprfl")?.removeEventListener("scroll", this.handleLightboxScroll);
    } else {
      document.removeEventListener("scroll", this.handlePageScroll);
    }

    window.removeEventListener("resize", this.handleResize);
  }

  getQueryParams = (incremental: any, keyword: any) => {
    const searchPage = incremental ? this.state.searchPage + 1 : 1;
    let query = keyword !== undefined ? ["search_term=", encodeURIComponent(keyword)] : [];

    const selectedRTs = this.state.resourceTypesSelected;
    // "Collection" joins on the first (non-incremental) search only. See legacy behaviour below.
    const defaultIncrementalTypes = ["Investigation", "Activity", "Interactive", "Assessment"];

    let requestedTypes: string[];
    if (selectedRTs.length === 0) {
      // no filter → legacy default
      requestedTypes = incremental
        ? defaultIncrementalTypes.slice()
        : defaultIncrementalTypes.concat(["Collection"]);
    } else {
      requestedTypes = selectedRTs.map(rt => rt.searchMaterialType);
    }

    // Collections are fetched in full (collection_per_page=1000) on non-incremental
    // calls, so drop them from incremental requests to avoid re-fetching the first
    // page and duplicating entries in searchCollections.
    if (incremental) {
      requestedTypes = requestedTypes.filter(t => t !== "Collection");
    }

    query = query.concat([
      "&skip_lightbox_reloads=true",
      "&sort_order=Alphabetical",
      "&include_related=0",
      "&investigation_page=", String(searchPage),
      "&activity_page=",      String(searchPage),
      "&interactive_page=",   String(searchPage),
      "&assessment_page=",    String(searchPage),
      "&per_page=",           String(DISPLAY_LIMIT_INCREMENT)
    ]);

    requestedTypes.forEach(t => {
      query.push("&material_types[]=");
      query.push(t);
    });

    if (!incremental && requestedTypes.indexOf("Collection") !== -1) {
      // Always fetch all matching collections in one page. In filtered mode they go to
      // the top of the unified list. In the landing state they feed FeaturedCollections.
      query.push("&collection_page=1");
      query.push("&collection_per_page=1000");
    }

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
    const searchPage = incremental ? this.state.searchPage + 1 : 1;
    const keyword = jQuery.trim(this.state.searchInput);

    // "Filtered mode": if any filter or keyword is active, collections join the unified list
    // at the top.
    const filteredMode =
      this.state.subjectAreasSelected.length > 0 ||
      this.state.gradeLevelsSelected.length > 0 ||
      this.state.resourceTypesSelected.length > 0 ||
      keyword.length > 0;

    // On incremental calls, split the prior unified resources state back into its
    // collections-prefix and non-collections-tail so the new accumulators stay clean.
    const prevUnified = incremental ? this.state.resources.slice(0) : [];
    const searchCollections: any[] = prevUnified.filter((r: any) => r.material_type === "Collection");
    const searchResources: any[] = prevUnified.filter((r: any) => r.material_type !== "Collection");
    /* eslint-enable react/no-access-state-in-setstate */

    // short circuit further incremental searches when all data has been downloaded
    if (incremental && (this.state.lastSearchResultCount === 0)) {
      this.setState({
        displayLimit
      });
      return;
    }

    // On any new search/filter, scroll the results list back to the top.
    if (!incremental && !this.state.firstSearch) {
      const finderResults = document.getElementById(css.finderResults);
      if (finderResults && !document.getElementById("finderLightbox")) {
        finderResults.scrollIntoView({ behavior: "smooth", block: "start" });
      }
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
      resources: [...searchCollections, ...searchResources]
    });

    jQuery.ajax({
      url: Portal.API_V1.SEARCH,
      data: this.getQueryParams(incremental, keyword),
      dataType: "json"
    }).done((result1: any) => {
      let numTotalResources = 0;
      const results = result1.results;
      const usersAuthoredResourcesCount = result1.filters.number_authored_resources;
      let lastSearchResultCount = 0;

      results.forEach((result: any) => {
        result.materials.forEach((material: any) => {
          portalObjectHelpers.processResource(material);
          if (material.material_type === "Collection") {
            if (filteredMode) {
              // Collections go to the top of the unified list, so count them in the total.
              searchCollections.push(material);
            } else {
              // Landing state: collections feed FeaturedCollections only. Do not mix into
              // the unified list and do not count in numTotalResources.
              featuredCollections.push(material);
            }
          } else {
            searchResources.push(material);
            lastSearchResultCount++;
          }
        });

        // Count collections toward numTotalResources only in filtered mode.
        if (result.type === "collections") {
          if (filteredMode) {
            numTotalResources += result.pagination.total_items;
          }
        } else {
          numTotalResources += result.pagination.total_items;
        }
      });

      if (featuredCollections.length > 1) {
        featuredCollections.sort(sortByName);
      }

      const sortedResources = sortResources(searchResources, this.state.sortOrder);
      // Collections always appear before other resources in filtered mode.
      // Sort them by the same sortOrder for internal ordering, but always keep
      // them grouped above the non-collection resources.
      const sortedCollections = sortResources(searchCollections, this.state.sortOrder);
      const unified = [...sortedCollections, ...sortedResources];

      if (this.state.firstSearch) {
        fadeIn(this);
      }

      this.setState({
        firstSearch: false,
        featuredCollections,
        resources: unified,
        numTotalResources,
        searchPage,
        displayLimit,
        searching: false,
        noResourcesFound: numTotalResources === 0,
        lastSearchResultCount,
        usersAuthoredResourcesCount
      });

      jQuery("#portal-pages-finder").removeClass("loading");

      this.showResources();
    });
  }

  buildFilterId (filterKey: any) {
    const filterKeyWords: string[] = filterKey.split("-");
    const filterId = filterKeyWords
      .map((word, idx) => idx === 0 ? word : word.charAt(0).toUpperCase() + word.slice(1))
      .join("");
    return filterId;
  }

  scrollToFinder () {
    if (document.getElementById("finderLightbox")) {
      document.getElementById("finderLightbox")?.scrollIntoView({ behavior: "smooth", block: "start", inline: "nearest" });
    }
  }

  noOptionsSelected () {
    return this.state.subjectAreasSelected.length === 0 &&
           this.state.gradeLevelsSelected.length === 0 &&
           this.state.resourceTypesSelected.length === 0;
  }

  renderLogo (subjectArea: any) {
    const filterId = this.buildFilterId(subjectArea.key);
    const selected = !!this.state.subjectAreasSelectedMap[subjectArea.key];
    const className = selected ? css.selected : undefined;

    const clicked = () => {
      this.setState((prev) => {
        const subjectAreasSelected = prev.subjectAreasSelected.slice();
        const subjectAreasSelectedMap = { ...prev.subjectAreasSelectedMap };
        const index = subjectAreasSelected.indexOf(subjectArea);

        if (index === -1) {
          subjectAreasSelectedMap[subjectArea.key] = subjectArea;
          subjectAreasSelected.push(subjectArea);
          gtag("event", "click", {
            "category": "Home Page Filter",
            "label": subjectArea.title
          });
        } else {
          delete subjectAreasSelectedMap[subjectArea.key];
          subjectAreasSelected.splice(index, 1);
        }
        this.scrollToFinder();
        return {
          subjectAreasSelected,
          subjectAreasSelectedMap,
          initPage: false
        };
      }, this.search);
    };

    const handleKeyDown = (e: React.KeyboardEvent<HTMLLIElement>) => {
      if (e.key === "Enter" || e.key === " ") {
        e.preventDefault();
        clicked();
      }
    };

    return (
      <li
        key={subjectArea.key}
        id={css[filterId]}
        className={className}
        onClick={clicked}
        onKeyDown={handleKeyDown}
        role="button"
        tabIndex={0}
        aria-pressed={selected}
      >
        { subjectArea.title }
      </li>
    );
  }

  renderGLLogo (gradeLevel: any) {
    const baseClassName = "portal-pages-finder-form-filters-logo";
    const filterId = this.buildFilterId(gradeLevel.key);

    const selected = !!this.state.gradeLevelsSelectedMap[gradeLevel.key];
    const className = selected ? `${baseClassName} ${css.selected}` : baseClassName;

    const clicked = () => {
      this.setState((prev) => {
        const gradeLevelsSelected = prev.gradeLevelsSelected.slice();
        const gradeLevelsSelectedMap = { ...prev.gradeLevelsSelectedMap };
        const index = gradeLevelsSelected.indexOf(gradeLevel);

        if (index === -1) {
          gradeLevelsSelectedMap[gradeLevel.key] = gradeLevel;
          gradeLevelsSelected.push(gradeLevel);
          gtag("event", "click", {
            "category": "Home Page Filter",
            "label": gradeLevel.title
          });
        } else {
          delete gradeLevelsSelectedMap[gradeLevel.key];
          gradeLevelsSelected.splice(index, 1);
        }
        this.scrollToFinder();
        return {
          gradeLevelsSelected,
          gradeLevelsSelectedMap,
          initPage: false
        };
      }, this.search);
    };

    const handleKeyDown = (e: React.KeyboardEvent<HTMLLIElement>) => {
      if (e.key === "Enter" || e.key === " ") {
        e.preventDefault();
        clicked();
      }
    };

    return (
      <li
        key={gradeLevel.key}
        id={css[filterId]}
        className={className}
        onClick={clicked}
        onKeyDown={handleKeyDown}
        role="button"
        tabIndex={0}
        aria-pressed={selected}
      >
        { gradeLevel.title }
      </li>
    );
  }

  renderRTLogo (resourceType: ResourceType) {
    const filterId = this.buildFilterId(resourceType.key);
    const selected = !!this.state.resourceTypesSelectedMap[resourceType.key];
    const className = selected ? css.selected : undefined;

    const toggle = () => {
      this.setState((prev) => {
        const resourceTypesSelected = prev.resourceTypesSelected.slice();
        const resourceTypesSelectedMap = { ...prev.resourceTypesSelectedMap };
        const index = resourceTypesSelected.indexOf(resourceType);

        if (index === -1) {
          resourceTypesSelectedMap[resourceType.key] = resourceType;
          resourceTypesSelected.push(resourceType);
          gtag("event", "click", {
            "category": "Home Page Filter",
            "label": resourceType.title
          });
        } else {
          delete resourceTypesSelectedMap[resourceType.key];
          resourceTypesSelected.splice(index, 1);
        }
        this.scrollToFinder();
        return {
          resourceTypesSelected,
          resourceTypesSelectedMap,
          initPage: false
        };
      }, this.search);
    };

    const handleKeyDown = (e: React.KeyboardEvent<HTMLLIElement>) => {
      if (e.key === "Enter" || e.key === " ") {
        e.preventDefault();
        toggle();
      }
    };

    return (
      <li
        key={resourceType.key}
        aria-pressed={selected}
        className={className}
        id={css[filterId]}
        role="button"
        tabIndex={0}
        onClick={toggle}
        onKeyDown={handleKeyDown}
      >
        { resourceType.title }
      </li>
    );
  }

  renderSubjectAreas () {
    const isOpen = this.state.sectionsOpen.subject;
    const containerClassName = isOpen
      ? `${css.finderOptionsContainer} ${css.open}`
      : css.finderOptionsContainer;
    return (
      <div className={containerClassName}>
        <h2
          data-section-key="subject"
          onClick={this.handleFilterHeaderClick}
          onKeyDown={this.handleFilterHeaderKeyDown}
          role="button"
          tabIndex={0}
          aria-expanded={isOpen}
        >
          Subject
        </h2>
        {isOpen && (
          <ul>
            { filters.subjectAreas.map((subjectArea: any) => {
              return this.renderLogo(subjectArea);
            }) }
          </ul>
        )}
      </div>
    );
  }

  renderGradeLevels () {
    const isOpen = this.state.sectionsOpen["grade-level"];
    const containerClassName = isOpen
      ? `${css.finderOptionsContainer} ${css.open}`
      : css.finderOptionsContainer;
    return (
      <div className={containerClassName}>
        <h2
          data-section-key="grade-level"
          onClick={this.handleFilterHeaderClick}
          onKeyDown={this.handleFilterHeaderKeyDown}
          role="button"
          tabIndex={0}
          aria-expanded={isOpen}
        >
          Grade Level
        </h2>
        {isOpen && (
          <ul>
            { filters.gradeFilters.map((gradeLevel: any) => {
              return this.renderGLLogo(gradeLevel);
            }) }
          </ul>
        )}
      </div>
    );
  }

  renderResourceTypes () {
    const isOpen = this.state.sectionsOpen["resource-type"];
    const containerClassName = isOpen
      ? `${css.finderOptionsContainer} ${css.open}`
      : css.finderOptionsContainer;


    return (
      <div className={containerClassName}>
        <h2
          data-section-key="resource-type"
          aria-expanded={isOpen}
          role="button"
          tabIndex={0}
          onClick={this.handleFilterHeaderClick}
          onKeyDown={this.handleFilterHeaderKeyDown}
        >
          Resource Type
        </h2>
        {isOpen && (
          <ul>
            { filters.resourceTypeFilters.map((rt: ResourceType) => this.renderRTLogo(rt)) }
          </ul>
        )}
      </div>
    );
  }

  handleOfficialClick = () => {
    this.setState((prev) => ({
      includeOfficial: !prev.includeOfficial
    }), this.search);
    gtag("event", "click", {
      "category": "Home Page Filter",
      "label": "Official"
    });
  };

  handleOfficialKeyDown = (e: React.KeyboardEvent<HTMLLIElement>) => {
    if (e.key === "Enter" || e.key === " ") {
      e.preventDefault();
      this.handleOfficialClick();
    }
  };

  handleCommunityClick = () => {
    this.setState((prev) => ({
      includeContributed: !prev.includeContributed
    }), this.search);
    gtag("event", "click", {
      "category": "Home Page Filter",
      "label": "Community"
    });
  };

  handleCommunityKeyDown = (e: React.KeyboardEvent<HTMLLIElement>) => {
    if (e.key === "Enter" || e.key === " ") {
      e.preventDefault();
      this.handleCommunityClick();
    }
  };

  clearFilters = () => {
    jQuery(".portal-pages-finder-form-subject-areas-logo").removeClass(css.selected);
    this.setState({
      subjectAreasSelected: [],
      subjectAreasSelectedMap: {},
      gradeLevelsSelected: [],
      gradeLevelsSelectedMap: {},
      resourceTypesSelected: [],
      resourceTypesSelectedMap: {},
      keyword: "",
      searchInput: ""
    }, this.search);
  };

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
      initPage: false,
    });
  };

  handleAutoSuggestSubmit = (searchInput: any) => {
    this.setState({
      initPage: false,
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
    const isOpen = this.state.sectionsOpen.keywords;
    const containerClassName = isOpen
      ? `${css.finderOptionsContainer} ${css.open}`
      : css.finderOptionsContainer;
    return (
      <div className={containerClassName}>
        <h2
          data-section-key="keywords"
          onClick={this.handleFilterHeaderClick}
          onKeyDown={this.handleFilterHeaderKeyDown}
          role="button"
          tabIndex={0}
          aria-expanded={isOpen}
        >
          Keywords
        </h2>
        {isOpen && (
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
        )}
      </div>
    );
  }

  isAdvancedUser () {
    const isAdvancedUser = Portal.currentUser.isAdmin || Portal.currentUser.isAuthor || Portal.currentUser.isManager || Portal.currentUser.isResearcher;
    return (isAdvancedUser);
  }

  renderAdvanced () {
    const isOpen = this.state.sectionsOpen.advanced;
    const containerClassName = isOpen
      ? `${css.finderOptionsContainer} ${css.open}`
      : css.finderOptionsContainer;
    return (
      <>
        <div className={containerClassName}>
          <h2
            data-section-key="advanced"
            onClick={this.handleFilterHeaderClick}
            onKeyDown={this.handleFilterHeaderKeyDown}
            role="button"
            tabIndex={0}
            aria-expanded={isOpen}
          >
            Advanced
          </h2>
          {isOpen && (
            <ul>
              <li
                id={css.official}
                aria-pressed={this.state.includeOfficial}
                className={this.state.includeOfficial ? css.selected : undefined}
                role="button"
                tabIndex={0}
                onClick={this.handleOfficialClick}
                onKeyDown={this.handleOfficialKeyDown}
              >
                Official
              </li>
              <li
                id={css.community}
                aria-pressed={this.state.includeContributed}
                className={this.state.includeContributed ? css.selected : undefined}
                role="button"
                tabIndex={0}
                onClick={this.handleCommunityClick}
                onKeyDown={this.handleCommunityKeyDown}
              >
                Community
              </li>
            </ul>
          )}
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
          { this.renderResourceTypes() }
          { isAdvancedUser && this.renderAdvanced() }
        </div>
      </div>
    );
  }

  handleFilterHeaderClick = (e: React.MouseEvent<HTMLElement> | React.KeyboardEvent<HTMLElement>) => {
    const key = (e.currentTarget as HTMLElement).dataset.sectionKey as SectionKey | undefined;
    if (!key) return;
    this.setState(prev => ({
      sectionsOpen: { ...prev.sectionsOpen, [key]: !prev.sectionsOpen[key] }
    }));
  };

  handleFilterHeaderKeyDown = (e: React.KeyboardEvent<HTMLHeadingElement>) => {
    if (e.key === "Enter" || e.key === " ") {
      e.preventDefault();
      this.handleFilterHeaderClick(e);
    }
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
        <select id="sort" name="sort" value={this.state.sortOrder} onChange={this.handleSortSelection}>
          { sortValues.map((sortValue, index) => {
            return <option key={`${sortValue}-${index}`} value={sortValue}>{ sortValue }</option>;
          }) }
        </select>
      </div>
    );
  }

  // Ref for the chip-bar container so we can recover focus after removal.
  // See the focus-management block in removeFilterChip below.
  chipBarRef: React.RefObject<HTMLDivElement> = React.createRef();

  removeFilterChip = (chip: SelectedFilterChip, removedIndex: number) => {
    this.setState(prev => {
      const next: any = {};
      switch (chip.kind) {
        case "subject":
          next.subjectAreasSelected = prev.subjectAreasSelected.filter(s => s.key !== chip.key);
          next.subjectAreasSelectedMap = { ...prev.subjectAreasSelectedMap };
          delete next.subjectAreasSelectedMap[chip.key];
          // The jQuery-driven left-rail render mutates the DOM. Reset its visible state here
          // by also toggling the `.selected` class off on the corresponding <li>.
          jQuery("#" + css[this.buildFilterId(chip.key)]).removeClass(css.selected);
          break;
        case "grade":
          next.gradeLevelsSelected = prev.gradeLevelsSelected.filter(g => g.key !== chip.key);
          next.gradeLevelsSelectedMap = { ...prev.gradeLevelsSelectedMap };
          delete next.gradeLevelsSelectedMap[chip.key];
          break;
        case "resourceType":
          next.resourceTypesSelected = prev.resourceTypesSelected.filter(rt => rt.key !== chip.key);
          next.resourceTypesSelectedMap = { ...prev.resourceTypesSelectedMap };
          delete next.resourceTypesSelectedMap[chip.key];
          break;
        case "keyword":
          next.keyword = "";
          next.searchInput = "";
          break;
      }
      return next;
    }, () => {
      // Focus management: the X button the user just activated has been unmounted.
      // If any chips remain, shift focus to a neighboring chip's X — the chip now at
      // `removedIndex`, or the new last chip if we removed the trailing one. If no
      // chips remain, the chip bar itself has unmounted (along with Clear filters),
      // so redirect focus to the sort <select>, rather than letting it fall to document.body.
      const bar = this.chipBarRef.current;
      if (bar) {
        const buttons = bar.querySelectorAll<HTMLButtonElement>("button");
        // Button ordering: [chip#0 ×, chip#1 ×, …, clear-filters]. The trailing
        // clear-filters button isn't a valid focus target for "next chip," so clamp
        // against `buttons.length - 2`.
        const lastChipIndex = buttons.length - 2;
        if (lastChipIndex >= 0) {
          const targetIndex = Math.min(removedIndex, lastChipIndex);
          buttons[targetIndex]?.focus();
        }
      } else {
        document.getElementById("sort")?.focus();
      }
      this.search();
    });
  };

  renderFilterChipBar () {
    const chips = buildSelectedFilterChips({
      subjectAreasSelected:  this.state.subjectAreasSelected,
      gradeLevelsSelected:   this.state.gradeLevelsSelected,
      resourceTypesSelected: this.state.resourceTypesSelected,
      keyword:               this.state.keyword || ""
    });

    if (chips.length === 0) return null;

    return (
      <div
        aria-label="Selected filters"
        className={css.filterChipBar}
        ref={this.chipBarRef}
        role="region"
      >
        { chips.map((chip, index) => (
          <FilterChip
            key={`${chip.kind}-${chip.key}`}
            label={chip.label}
            onRemove={() => this.removeFilterChip(chip, index)}
          />
        )) }
        <button
          className={css.clearFiltersButton}
          type="button"
          onClick={() => this.clearFilters()}
        >
          Clear filters
        </button>
      </div>
    );
  }

  renderResultsHeader () {
    const { noResourcesFound, numTotalResources, searching, usersAuthoredResourcesCount } = this.state;

    let countLabel: React.ReactNode;
    if (searching) {
      countLabel = "Loading…";
    } else if (noResourcesFound || numTotalResources === 0) {
      countLabel = "No results matching your search";
    } else {
      countLabel = `${numTotalResources} ${pluralize(numTotalResources, "result", "results")}`;
    }

    return (
      <div className={css.finderHeader}>
        <div className={css.finderHeaderTop}>
          <div className={css.finderHeaderResourceCount}>{countLabel}</div>
          {this.renderSortMenu()}
          {(this.isAdvancedUser() || usersAuthoredResourcesCount > 0) && this.renderShowOnly()}
        </div>
        {this.renderFilterChipBar()}
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

  renderResults () {
    if (this.state.firstSearch) {
      return (
        <div className={css.loading}>
          Loading
        </div>
      );
    }

    // Landing state: show FeaturedCollections strip (no filters, no keyword, initial page).
    const showFeaturedStrip =
      !this.props.hideFeatured &&
      this.state.initPage &&
      this.noOptionsSelected() &&
      (this.state.keyword || "").trim().length === 0 &&
      this.state.featuredCollections.length > 0;

    const featured = showFeaturedStrip
      ? this.state.featuredCollections.slice().sort(() => Math.random() - Math.random()).slice(0, 3)
      : [];


    const resources = this.state.resources.slice(0, this.state.displayLimit);

    return (
      <>
        { showFeaturedStrip && <FeaturedCollections featuredCollections={featured} /> }
        { this.renderResultsHeader() }
        <div className={css.finderResultsContainer}>
          { resources.map((resource: any, index: any) => (
            <StemFinderResult key={`${resource.external_url}-${index}`} resource={resource} index={index} showResources={this.showResources} />
          )) }
        </div>
        { this.renderLoadMore() }
        { this.state.searching ? <div className={css.loading}>Loading</div> : null }
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
