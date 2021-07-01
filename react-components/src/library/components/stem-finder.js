import React from 'react'

import Component from '../helpers/component'
import stemFinderResult from '../components/stem-finder-result'
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
    let projectId = this.props.projectId || null
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

    let projectsSelected = []
    if (projectId) {
      projectsSelected.push(projectId)
    }

    // console.log("INFO stem-finder initial subject areas: ", subjectAreasSelected);

    return {
      opacity: 1,
      subjectAreasSelected: subjectAreasSelected,
      subjectAreasSelectedMap: subjectAreasSelectedMap,
      gradeLevelsSelected: gradeLevelsSelected,
      gradeLevelsSelectedMap: gradeLevelsSelectedMap,
      projectsSelected: projectsSelected,
      sortOrder: sortOrder,
      collections: [],
      resources: [],
      numTotalResources: 0,
      displayLimit: DISPLAY_LIMIT_INCREMENT,
      searchPage: 1,
      firstSearch: true,
      searching: false,
      noResourcesFound: false,
      lastSearchResultCount: 0,
      keyword: '',
      searchInput: '',
      initPage: true,
      featuredCollections: [],
      hideFeatured: hideFeatured,
      includeOfficial: true,
      includeContributed: false
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
      jQuery.ajax({
        url: '/api/v1/projects', // TODO: replace with Portal.API_V1 constant when available
        dataType: 'json'
      }).done(function (data) {
        let collections = data.reduce(function (collections, collection) {
          if (collection.landing_page_slug) {
            collection.filteredDescription = portalObjectHelpers.textOfHtml(collection.project_card_description)
            collections.push(collection)
          }
          return collections
        }, [])
        if (collections.length > 0) {
          collections.sort(sortByName)
        }
        this.setState({ collections: collections })
      }.bind(this))
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
      '&include_official=',
      this.state.includeOfficial,
      '&include_contributed=',
      this.state.includeContributed,
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

    // project
    this.state.projectsSelected.forEach(function (project) {
      if (project) {
        query.push('&project_ids[]=')
        query.push(encodeURIComponent(project))
      }
    })

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
      ga('send', 'event', 'Home Page Search', 'Search', keyword)
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

      console.log(featuredCollections)
      // if (featuredCollections.length > 1) {
      //   featuredCollections.sort(sortByName)
      // }
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
        lastSearchResultCount: lastSearchResultCount
      })
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
    let className = 'portal-pages-finder-form-subject-areas-logo'
    const filterId = this.buildFilterId(subjectArea.key)

    var selected = this.state.subjectAreasSelectedMap[subjectArea.key]
    if (selected) {
      className += ' ' + css.selected
    }

    const clicked = function () {
      const subjectAreasSelected = this.state.subjectAreasSelected.slice()
      const subjectAreasSelectedMap = this.state.subjectAreasSelectedMap
      const index = subjectAreasSelected.indexOf(subjectArea)

      if (index === -1) {
        subjectAreasSelectedMap[subjectArea.key] = subjectArea
        subjectAreasSelected.push(subjectArea)
        jQuery('#' + css[filterId]).addClass(css.selected)
        ga('send', 'event', 'Home Page Filter', 'Click', subjectArea.title)
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
        ga('send', 'event', 'Home Page Filter', 'Click', gradeLevel.title)
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
    return (
      <div className={`${css.finderOptionsContainer} ${css.open}`}>
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
    return (
      <div className={`${css.finderOptionsContainer} ${css.open}`}>
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
  },

  handleCommunityClick: function (e) {
    e.currentTarget.classList.toggle(css.selected)
    this.setState({
      hideFeatured: true,
      includeCommunity: !this.state.includeCommunity
    }, this.search)
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
      ga('send', 'event', 'Home Page Filter', 'Click', filter.title)
    } else {
      selectedFilters.splice(index, 1)
      jQuery('#' + filter.key).removeClass(css.selected)
    }
    let state = {}
    state[selectedKey] = selectedFilters
    this.setState(state, this.search)
  },

  renderFilters: function (type, title) {
    return (
      <div className={'portal-pages-finder-form-filters'}>
        <div className={'portal-pages-finder-form-filters-title'}>
          {title}
        </div>
        <ul className={'portal-pages-finder-form-filters-options'}>
          {filters[type].map(function (filter) {
            const selectedKey = type + 'Selected'
            const handleChange = function () {
              this.scrollToFinder()
              this.toggleFilter(type, filter)
            }.bind(this)
            const checked = this.state[selectedKey].indexOf(filter) !== -1
            return (
              <li key={filter.key} className={'portal-pages-finder-form-filters-option'}>
                <input type={'checkbox'} id={filter.key} name={filter.key} onChange={handleChange} checked={checked} />
                <label htmlFor={filter.key}>
                  {filter.title}
                </label>
              </li>
            )
          }.bind(this))}
        </ul>
      </div>
    )
  },

  handleSearchInputChange: function (searchInput) {
    this.setState({ searchInput })
  },

  handleSearchSubmit (e) {
    e.preventDefault()
    e.stopPropagation()
    this.search()
    this.scrollToFinder()
    this.setState({
      hideFeatured: true,
      initPage: false
    })
  },

  handleAutoSuggestSubmit (searchInput) {
    this.setState({
      hideFeatured: true,
      initPage: false
    })
    this.setState({ searchInput }, () => {
      this.search()
      this.scrollToFinder()
    })
  },

  handleCollectionSelection (e) {
    e.preventDefault()
    e.stopPropagation()
    this.setState({
      hideFeatured: true,
      initPage: false
    })
    this.setState({ projectsSelected: [e.target.value] }, () => {
      this.search()
    })
  },

  handleSortSelection (e) {
    e.preventDefault()
    e.stopPropagation()
    this.setState({
      hideFeatured: true,
      initPage: false
    })
    this.setState({ sortOrder: e.target.value }, () => {
      this.search()
    })
  },

  renderSearch: function () {
    return (
      <div className={`${css.finderOptionsContainer} ${css.open}`}>
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

  renderCollections: function () {
    if (!this.state.collections || this.state.collections.length === 0) {
      return
    }
    const collections = this.state.collections
    return (
      <div className={`${css.finderOptionsContainer} ${css.open}`}>
        <h2 onClick={this.handleFilterHeaderClick}>Collections</h2>
        <select name='collections' value={this.state.projectsSelected[0]} className={css.collectionSelect} onChange={this.handleCollectionSelection}>
          <option value=''>Select one...</option>
          {collections.map(function (collection, index) {
            return <option value={collection.id}>{collection.name}</option>
          })}
        </select>
      </div>
    )
  },

  renderAdvanced: function () {
    return (
      <div className={css.finderOptionsContainer}>
        <h2 onClick={this.handleFilterHeaderClick}>Advanced</h2>
        <ul>
          <li id={css.official} className={css.selected} onClick={(e) => this.handleOfficialClick(e)}>Official</li>
          <li id={css.community} onClick={(e) => this.handleCommunityClick(e)}>Community</li>
        </ul>
      </div>
    )
  },

  renderForm: function () {
    return (
      <div className={'col-3 ' + css.finderForm}>
        <div className={'portal-pages-finder-form-inner'} style={{ opacity: this.state.opacity }}>
          {this.renderSearch()}
          {this.renderCollections()}
          {this.renderSubjectAreas()}
          {this.renderGradeLevels()}
          {this.renderAdvanced()}
        </div>
      </div>
    )
  },

  handleFilterHeaderClick: function (e) {
    e.currentTarget.parentElement.classList.toggle(css.open)
  },

  renderSortMenu: function () {
    const sortValues = ['Title', 'Less time required', 'More time required', 'Newest', 'Oldest']

    return (
      <div className={css.sortMenu}>
        <label htmlFor='sort'>Sort by</label>
        <select name='sort' value={this.state.sortOrder} onChange={this.handleSortSelection}>
          <option value=''>Select one...</option>
          {sortValues.map(function (sortValue, index) {
            return <option value={sortValue}>{sortValue}</option>
          })}
        </select>
      </div>
    )
  },

  renderResultsHeader: function () {
    if (this.state.noResourcesFound || this.state.searching) {
      return (
        <div className={css.finderHeader}>
          <div className={css.finderHeaderResourceCount}>
            {this.state.noResourcesFound ? 'No Resources Found' : ''}
          </div>
          {this.renderSortMenu()}
        </div>
      )
    }

    const showingAll = this.state.displayLimit >= this.state.numTotalResources
    const multipleResources = this.state.numTotalResources > 1
    const resourceCount = showingAll ? this.state.numTotalResources : this.state.displayLimit + ' of ' + this.state.numTotalResources
    jQuery('#portal-pages-finder').removeClass('loading')
    return (
      <div className={css.finderHeader}>
        <h2>Activities List</h2>
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
    // const handleLoadAll = function () {
    //   if (!this.state.searching) {
    //     this.search(true)
    //   }
    //   ga('send', 'event', 'Load More Button', 'Click', this.state.displayLimit + ' resources displayed')
    // }.bind(this)
    if ((this.state.resources.length === 0) || (this.state.displayLimit >= this.state.numTotalResources)) {
      return null
    }
    // return (
    //   <div className={'portal-pages-finder-load-all center'} onClick={handleLoadAll}>
    //     <button>
    //       {this.state.searching ? 'Loading...' : 'Load More'}
    //     </button>
    //   </div>
    // )
  },

  renderResults: function () {
    if (this.state.firstSearch) {
      return (
        <div class={css.loading}>
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
          {resources.map(function (resource, index) {
            return stemFinderResult({ key: `${index}-${resource.external_url}`, resource: resource })
          })}
        </div>
        {this.state.searching ? <div class={css.loading}>Loading</div> : null}
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
