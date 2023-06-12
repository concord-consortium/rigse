import React from 'react'

import Component from '../helpers/component'
import StemFinderResult from '../components/stem-finder-result'
import sortByName from '../helpers/sort-by-name'
import sortResources from '../helpers/sort-resources'
import fadeIn from '../helpers/fade-in'
import pluralize from '../helpers/pluralize'
import waitForAutoShowingLightboxToClose from '../helpers/wait-for-auto-lightbox-to-close'
import filters from '../helpers/filters'
import portalObjectHelpers from '../helpers/portal-object-helpers'
import AutoSuggest from './search/auto-suggest'
import FeaturedCollections from './featured-collections/featured-collections'

import css from './stem-finder.scss'

const DISPLAY_LIMIT_INCREMENT = 6

const StemFinder = Component({

  getInitialState: function () {
    const hideFeatured = this.props.hideFeatured || false
    let subjectAreaKey = this.props.subjectAreaKey
    let gradeLevelKey = this.props.gradeLevelKey
    let sortOrder = this.props.sortOrder || ''

    if (!subjectAreaKey && !gradeLevelKey) {
      //
      // If we are not passed props indicating filters to pre-populate
      // then attempt to see if this information is available in the URL.
      //
      const params = this.getFiltersFromURL()
      subjectAreaKey = params.subject
      gradeLevelKey = params['grade-level']

      subjectAreaKey = this.mapSubjectArea(subjectAreaKey)
    }

    //
    // Scroll to stem finder if we have filters specified.
    //
    if (subjectAreaKey || gradeLevelKey) {
      // this.scrollToFinder()
    }

    let subjectAreasSelected = []
    let subjectAreasSelectedMap = {}
    let i

    if (subjectAreaKey) {
      let subjectAreas = filters.subjectAreas
      for (i = 0; i < subjectAreas.length; i++) {
        let subjectArea = subjectAreas[i]
        if (subjectArea.key === subjectAreaKey) {
          subjectAreasSelected.push(subjectArea)
          subjectAreasSelectedMap[subjectArea.key] = subjectArea
        }
      }
    }

    let gradeLevelsSelected = []
    let gradeLevelsSelectedMap = {}

    if (gradeLevelKey) {
      let gradeLevels = filters.gradeLevels
      for (i = 0; i < gradeLevels.length; i++) {
        let gradeLevel = gradeLevels[i]
        if (gradeLevel.key === gradeLevelKey) {
          gradeLevelsSelected.push(gradeLevel)
          gradeLevelsSelectedMap[gradeLevel.key] = gradeLevel
        }
      }
    }

    // console.log("INFO stem-finder initial subject areas: ", subjectAreasSelected);

    return {
      collections: [],
      displayLimit: DISPLAY_LIMIT_INCREMENT,
      featuredCollections: [],
      firstSearch: true,
      gradeLevelsSelected: gradeLevelsSelected,
      gradeLevelsSelectedMap: gradeLevelsSelectedMap,
      hideFeatured: hideFeatured,
      includeOfficial: true,
      includeContributed: false,
      includeMine: false,
      initPage: true,
      isSmallScreen: window.innerWidth <= 768,
      keyword: '',
      lastSearchResultCount: 0,
      noResourcesFound: false,
      numTotalResources: 0,
      opacity: 1,
      resources: [],
      searching: false,
      searchInput: '',
      searchPage: 1,
      sortOrder: sortOrder,
      subjectAreasSelected: subjectAreasSelected,
      subjectAreasSelectedMap: subjectAreasSelectedMap,
      usersAuthoredResourcesCount: 0
    }
  },

  //
  // If the current URL is formatted to include stem finder filters,
  // return the filters specified in the URL as filter-name => filter-value
  // pairs.
  //
  getFiltersFromURL: function () {
    let ret = {}

    let path = window.location.pathname
    if (!path.startsWith('/')) { path = '/' + path }

    let parts = path.split('/')

    if (parts.length >= 4 && parts[1] === 'resources') {
      ret[parts[2]] = parts[3]
    }

    return ret
  },

  mapSubjectArea: function (subjectArea) {
    switch (subjectArea) {
      case 'biology':
      case 'life-science':
        return 'life-sciences'
      case 'engineering':
        return 'engineering-tech'
    }
    return subjectArea
  },

  UNSAFE_componentWillMount: function () {
    waitForAutoShowingLightboxToClose(function () {
      this.search()
    }.bind(this))
  },

  handlePageScroll: function (event) {
    const scrollTop = document.documentElement.scrollTop || document.body.scrollTop
    if (
      scrollTop > window.innerHeight / 2 &&
      !this.state.searching &&
      this.state.resources.length !== 0 &&
      !(this.state.displayLimit >= this.state.numTotalResources)
    ) {
      this.search(true)
    }
  },

  handleLightboxScroll: function (event) {
    const scrollTop = event.srcElement.scrollTop
    if (
      scrollTop > window.innerHeight / 3 &&
      !this.state.searching &&
      this.state.resources.length !== 0 &&
      !(this.state.displayLimit >= this.state.numTotalResources)
    ) {
      this.search(true)
    }
  },

  componentDidMount: function () {
    if (document.getElementById('pprfl')) {
      document.getElementById('pprfl').addEventListener('scroll', this.handleLightboxScroll)
    } else {
      document.addEventListener('scroll', this.handlePageScroll)
    }

    window.addEventListener('resize', () => {
      this.setState({ isSmallScreen: window.innerWidth <= 768 })
    })
  },

  componentWillUnmount: function () {
    if (document.getElementById('pprfl')) {
      document.getElementById('pprfl').removeEventListener('scroll', this.handleLightboxScroll)
    } else {
      document.removeEventListener('scroll', this.handlePageScroll)
    }
  },

  getQueryParams: function (incremental, keyword) {
    const searchPage = incremental ? this.state.searchPage + 1 : 1
    let query = keyword !== undefined ? ['search_term=', encodeURIComponent(keyword)] : []
    query = query.concat([
      '&skip_lightbox_reloads=true',
      '&sort_order=Alphabetical',
      '&model_types=All',
      '&include_related=0',
      '&investigation_page=',
      searchPage,
      '&activity_page=',
      searchPage,
      '&interactive_page=',
      searchPage,
      '&collection_page=',
      searchPage,
      '&per_page=',
      DISPLAY_LIMIT_INCREMENT
    ])

    // subject areas
    this.state.subjectAreasSelected.forEach(function (subjectArea) {
      subjectArea.searchAreas.forEach(function (searchArea) {
        query.push('&subject_areas[]=')
        query.push(encodeURIComponent(searchArea))
      })
    })

    // grade
    this.state.gradeLevelsSelected.forEach(function (gradeFilter) {
      if (gradeFilter.searchGroups) {
        gradeFilter.searchGroups.forEach(function (searchGroup) {
          query.push('&grade_level_groups[]=')
          query.push(encodeURIComponent(searchGroup))
        })
      }
      // TODO: informal learning?
    })

    let includedResources = this.state.includeMine ? '&include_mine=1' : ''
    includedResources += this.state.includeOfficial ? '&include_official=1' : ''
    includedResources += this.state.includeContributed ? '&include_contributed=1' : ''
    query.push(includedResources)

    return query.join('')
  },

  search: function (incremental) {
    let displayLimit = incremental ? this.state.displayLimit + DISPLAY_LIMIT_INCREMENT : DISPLAY_LIMIT_INCREMENT

    // short circuit further incremental searches when all data has been downloaded
    if (incremental && (this.state.lastSearchResultCount === 0)) {
      this.setState({
        displayLimit: displayLimit
      })
      return
    }

    let featuredCollections = incremental ? this.state.featuredCollections.slice(0) : []
    let resources = incremental ? this.state.resources.slice(0) : []
    let searchPage = incremental ? this.state.searchPage + 1 : 1

    let keyword = jQuery.trim(this.state.searchInput)
    if (keyword !== '') {
      gtag('event', 'search', {
        'category': 'Home Page Search',
        'action': 'search',
        'label': keyword,
      });
    }

    this.setState({
      keyword,
      searching: true,
      noResourcesFound: false,
      featuredCollections: featuredCollections,
      resources: resources
    })

    jQuery.ajax({
      url: Portal.API_V1.SEARCH,
      data: this.getQueryParams(incremental, keyword),
      dataType: 'json'
    }).done(function (result) {
      let numTotalResources = 0
      const results = result.results
      const usersAuthoredResourcesCount = result.filters.number_authored_resources
      let lastSearchResultCount = 0

      results.forEach(function (result) {
        result.materials.forEach(function (material) {
          portalObjectHelpers.processResource(material)
          resources.push(material)
          if (material.material_type === 'Collection') {
            featuredCollections.push(material)
          }
          lastSearchResultCount++
        })
        numTotalResources += result.pagination.total_items
      })

      if (featuredCollections.length > 1) {
        featuredCollections.sort(sortByName)
      }
      resources = sortResources(resources, this.state.sortOrder)

      if (this.state.firstSearch) {
        fadeIn(this, 1000)
      }

      this.setState({
        firstSearch: false,
        featuredCollections: featuredCollections,
        resources: resources,
        numTotalResources: numTotalResources,
        searchPage: searchPage,
        displayLimit: displayLimit,
        searching: false,
        noResourcesFound: numTotalResources === 0,
        lastSearchResultCount: lastSearchResultCount,
        usersAuthoredResourcesCount: usersAuthoredResourcesCount
      })

      this.showResources()
    }.bind(this))
  },

  buildFilterId: function (filterKey) {
    const filterKeyWords = filterKey.split('-')
    const filterId = filterKeyWords.length > 1
      ? filterKeyWords[0] + filterKeyWords[1].charAt(0).toUpperCase() + filterKeyWords[1].slice(1)
      : filterKeyWords[0]
    return filterId
  },

  scrollToFinder: function () {
    if (document.getElementById('finderLightbox')) {
      document.getElementById('finderLightbox').scrollIntoView({ behavior: 'smooth', block: 'start', inline: 'nearest' })
    }
  },

  noOptionsSelected: function () {
    if (
      this.state.subjectAreasSelected.length === 0 &&
      this.state.gradeLevelsSelected.length === 0
    ) {
      return true
    } else {
      return false
    }
  },

  renderLogo: function (subjectArea) {
    const filterId = this.buildFilterId(subjectArea.key)
    const selected = this.state.subjectAreasSelectedMap[subjectArea.key]
    const className = selected ? css.selected : null

    const clicked = function () {
      const subjectAreasSelected = this.state.subjectAreasSelected.slice()
      const subjectAreasSelectedMap = this.state.subjectAreasSelectedMap
      const index = subjectAreasSelected.indexOf(subjectArea)

      if (index === -1) {
        subjectAreasSelectedMap[subjectArea.key] = subjectArea
        subjectAreasSelected.push(subjectArea)
        jQuery('#' + css[filterId]).addClass(css.selected)
        gtag('event', 'click', {
          'category': 'Home Page Filter',
          'label': subjectArea.title,
        });

      } else {
        subjectAreasSelectedMap[subjectArea.key] = undefined
        subjectAreasSelected.splice(index, 1)
        jQuery('#' + css[filterId]).removeClass(css.selected)
      }
      // console.log("INFO subject areas", subjectAreasSelected);
      this.setState({ subjectAreasSelected: subjectAreasSelected, subjectAreasSelectedMap: subjectAreasSelectedMap }, this.search)
      this.scrollToFinder()
      this.setState({
        hideFeatured: true,
        initPage: false
      })
    }.bind(this)

    return (
      <li key={subjectArea.key} id={css[filterId]} className={className} onClick={clicked}>
        {subjectArea.title}
      </li>
    )
  },

  renderGLLogo: function (gradeLevel) {
    let className = 'portal-pages-finder-form-filters-logo'
    const filterId = this.buildFilterId(gradeLevel.key)

    var selected = this.state.gradeLevelsSelectedMap[gradeLevel.key]
    if (selected) {
      className += ' ' + css.selected
    }

    const clicked = function () {
      const gradeLevelsSelected = this.state.gradeLevelsSelected.slice()
      const gradeLevelsSelectedMap = this.state.gradeLevelsSelectedMap
      const index = gradeLevelsSelected.indexOf(gradeLevel)

      if (index === -1) {
        gradeLevelsSelectedMap[gradeLevel.key] = gradeLevel
        gradeLevelsSelected.push(gradeLevel)
        jQuery('#' + css[filterId]).addClass(css.selected)
        gtag('event', 'click', {
          'category': 'Home Page Filter',
          'label': gradeLevel.title,
        });
      } else {
        gradeLevelsSelectedMap[gradeLevel.key] = undefined
        gradeLevelsSelected.splice(index, 1)
        jQuery('#' + css[filterId]).removeClass(css.selected)
      }
      // console.log("INFO subject areas", subjectAreasSelected);
      this.setState({ gradeLevelsSelected: gradeLevelsSelected, gradeLevelsSelectedMap: gradeLevelsSelectedMap }, this.search)
      this.scrollToFinder()
      this.setState({
        hideFeatured: true,
        initPage: false
      })
    }.bind(this)

    return (
      <li key={gradeLevel.key} id={css[filterId]} className={className} onClick={clicked}>
        {gradeLevel.title}
      </li>
    )
  },

  renderSubjectAreas: function () {
    const containerClassName = this.state.isSmallScreen ? css.finderOptionsContainer : `${css.finderOptionsContainer} ${css.open}`
    return (
      <div className={containerClassName}>
        <h2 onClick={this.handleFilterHeaderClick}>Subject</h2>
        <ul>
          {filters.subjectAreas.map(function (subjectArea) {
            return this.renderLogo(subjectArea)
          }.bind(this))}
        </ul>
      </div>
    )
  },

  renderGradeLevels: function () {
    const containerClassName = this.state.isSmallScreen ? css.finderOptionsContainer : `${css.finderOptionsContainer} ${css.open}`
    return (
      <div className={containerClassName}>
        <h2 onClick={this.handleFilterHeaderClick}>Grade Level</h2>
        <ul>
          {filters.gradeFilters.map(function (gradeLevel) {
            return this.renderGLLogo(gradeLevel)
          }.bind(this))}
        </ul>
      </div>
    )
  },

  handleOfficialClick: function (e) {
    e.currentTarget.classList.toggle(css.selected)
    this.setState({
      hideFeatured: true,
      includeOfficial: !this.state.includeOfficial
    }, this.search)
    gtag('event', 'click', {
      'category': 'Home Page Filter',
      'label': 'Official',
    });
  },

  handleCommunityClick: function (e) {
    e.currentTarget.classList.toggle(css.selected)
    this.setState({
      hideFeatured: true,
      includeContributed: !this.state.includeContributed
    }, this.search)
    gtag('event', 'click', {
      'category': 'Home Page Filter',
      'label': 'Community',
    });
  },

  clearFilters: function () {
    jQuery('.portal-pages-finder-form-subject-areas-logo').removeClass(css.selected)
    this.setState({
      subjectAreasSelected: [],
      gradeLevelsSelected: [],
      keyword: '',
      searchInput: ''
    }, this.search)
  },

  clearKeyword: function () {
    this.setState({ keyword: '', searchInput: '' }, () => this.search())
  },

  toggleFilter: function (type, filter) {
    this.setState({ initPage: false })
    const selectedKey = type + 'Selected'
    const selectedFilters = this.state[selectedKey].slice()
    const index = selectedFilters.indexOf(filter)
    if (index === -1) {
      selectedFilters.push(filter)
      jQuery('#' + filter.key).addClass(css.selected)
      gtag('event', 'click', {
        'category': 'Home Page Filter',
        'label': filter.title,
      });
    } else {
      selectedFilters.splice(index, 1)
      jQuery('#' + filter.key).removeClass(css.selected)
    }
    let state = {}
    state[selectedKey] = selectedFilters
    this.setState(state, this.search)
  },

  handleSearchInputChange: function (searchInput) {
    this.setState({ searchInput })
  },

  handleSearchSubmit(e) {
    e.preventDefault()
    e.stopPropagation()
    this.search()
    this.scrollToFinder()
    this.setState({
      hideFeatured: true,
      initPage: false
    })
  },

  handleAutoSuggestSubmit(searchInput) {
    this.setState({
      hideFeatured: true,
      initPage: false
    })
    this.setState({ searchInput }, () => {
      this.search()
      this.scrollToFinder()
    })
  },

  handleSortSelection(e) {
    e.preventDefault()
    e.stopPropagation()
    this.setState({
      hideFeatured: true,
      initPage: false
    })
    this.setState({ sortOrder: e.target.value }, () => {
      this.search()
    })

    gtag('event', 'selection', {
      'category': 'Finder Sort',
      'label': e.target.value,
    });
  },

  renderSearch: function () {
    const containerClassName = this.state.isSmallScreen ? css.finderOptionsContainer : `${css.finderOptionsContainer} ${css.open}`
    return (
      <div className={containerClassName}>
        <h2 onClick={this.handleFilterHeaderClick}>Keywords</h2>
        <form onSubmit={this.handleSearchSubmit}>
          <div className={'portal-pages-search-input-container'}>
            <AutoSuggest
              name={'search-terms'}
              query={this.state.searchInput}
              getQueryParams={this.getQueryParams}
              onChange={this.handleSearchInputChange}
              onSubmit={this.handleAutoSuggestSubmit}
              placeholder={'Type search term here'}
              skipAutoSearch
            />
          </div>
        </form>
      </div>
    )
  },

  isAdvancedUser: function () {
    const isAdvancedUser = Portal.currentUser.isAdmin || Portal.currentUser.isAuthor || Portal.currentUser.isManager || Portal.currentUser.isResearcher
    return (isAdvancedUser)
  },

  renderAdvanced: function () {
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
          <a href='/search' title='Advanced Search'>Advanced Search</a>
        </div>
      </>
    )
  },

  renderForm: function () {
    const isAdvancedUser = this.isAdvancedUser()
    return (
      <div className={'col-3 ' + css.finderForm}>
        <div className={'portal-pages-finder-form-inner'} style={{ opacity: this.state.opacity }}>
          {this.renderSearch()}
          {this.renderSubjectAreas()}
          {this.renderGradeLevels()}
          {isAdvancedUser && this.renderAdvanced()}
        </div>
      </div>
    )
  },

  handleFilterHeaderClick: function (e) {
    e.currentTarget.parentElement.classList.toggle(css.open)
  },

  handleShowOnlyMine: function (e) {
    this.setState({ includeMine: !this.state.includeMine }, this.search)
  },

  renderShowOnly: function () {
    const { includeMine } = this.state
    return (
      <div className={css.showOnly}>
        <label htmlFor='includeMine'><input type='checkbox' name='includeMine' value='true' id='includeMine' onChange={this.handleShowOnlyMine} defaultChecked={includeMine} /> Show only resources I authored</label>
      </div>
    )
  },

  renderSortMenu: function () {
    const sortValues = ['Alphabetical', 'Newest', 'Oldest']

    return (
      <div className={css.sortMenu}>
        <label htmlFor='sort'>Sort by</label>
        <select name='sort' value={this.state.sortOrder} onChange={this.handleSortSelection}>
          {sortValues.map(function (sortValue, index) {
            return <option key={`${sortValue}-${index}`} value={sortValue}>{sortValue}</option>
          })}
        </select>
      </div>
    )
  },

  renderResultsHeader: function () {
    const { displayLimit, noResourcesFound, numTotalResources, searching, usersAuthoredResourcesCount } = this.state
    const finderHeaderClass = this.isAdvancedUser() || usersAuthoredResourcesCount > 0 ? `${css.finderHeader} ${css.advanced}` : css.finderHeader

    if (noResourcesFound || searching) {
      return (
        <div className={finderHeaderClass}>
          <h2>Activities List</h2>
          {(this.isAdvancedUser() || usersAuthoredResourcesCount > 0) && this.renderShowOnly()}
          <div className={css.finderHeaderResourceCount}>
            {noResourcesFound ? 'No Resources Found' : 'Loading...'}
          </div>
          {this.renderSortMenu()}
        </div>
      )
    }

    const showingAll = displayLimit >= numTotalResources
    const multipleResources = numTotalResources > 1
    const resourceCount = showingAll ? numTotalResources : displayLimit + ' of ' + numTotalResources
    jQuery('#portal-pages-finder').removeClass('loading')
    return (
      <div className={finderHeaderClass}>
        <h2>Activities List</h2>
        {(this.isAdvancedUser() || usersAuthoredResourcesCount > 0) && this.renderShowOnly()}
        <div className={css.finderHeaderResourceCount}>
          {showingAll && multipleResources ? 'Showing All ' : 'Showing '}
          <strong>
            {resourceCount + ' ' + pluralize(resourceCount, 'Activity', 'Activities')}
          </strong>
        </div>
        {this.renderSortMenu()}
      </div>
    )
  },

  renderLoadMore: function () {
    if ((this.state.resources.length === 0) || (this.state.displayLimit >= this.state.numTotalResources)) {
      return null
    }
  },

  showResources: function () {
    setTimeout(function () {
      const resourceItems = document.querySelectorAll('.resourceItem')
      resourceItems.forEach(function (resourceItem) { resourceItem.style.opacity = 1 })
    }, 500)
  },

  renderResults: function () {
    if (this.state.firstSearch) {
      return (
        <div className={css.loading}>
          Loading
        </div>
      )
    }

    let featuredCollections = this.state.featuredCollections
    featuredCollections = featuredCollections.sort(() => Math.random() - Math.random()).slice(0, 3)
    const resources = this.state.resources.slice(0, this.state.displayLimit)
    return (
      <>
        {(!this.state.hideFeatured && this.state.initPage && this.noOptionsSelected() && featuredCollections.length > 0) &&
          <FeaturedCollections featuredCollections={featuredCollections} />
        }
        {this.renderResultsHeader()}
        <div className={css.finderResultsContainer}>
          {resources.map((resource, index) => {
            return <StemFinderResult key={`${resource.external_url}-${index}`} resource={resource} index={index} showResources={this.showResources} />
          })}
        </div>
        {this.state.searching ? <div className={css.loading}>Loading</div> : null}
        {this.renderLoadMore()}
      </>
    )
  },

  render: function () {
    // console.log("INFO stem-finder render()");
    return (
      <div className={'cols ' + css.finderWrapper}>
        {this.renderForm()}
        <div id={css.finderResults} className='portal-pages-finder-results col-9' style={{ opacity: this.state.opacity }}>
          {this.renderResults()}
        </div>
      </div>
    )
  }
})

export default StemFinder
