import React from 'react'

import Component from '../helpers/component'
import StemFinderResult from '../components/stem-finder-result'
import HeaderFilter from '../components/header-filter'
import sortByName from '../helpers/sort-by-name'
import fadeIn from '../helpers/fade-in'
import pluralize from '../helpers/pluralize'
import waitForAutoShowingLightboxToClose from '../helpers/wait-for-auto-lightbox-to-close'
import filters from '../helpers/filters'
import portalObjectHelpers from '../helpers/portal-object-helpers'
import AutoSuggest from './search/auto-suggest'

const DISPLAY_LIMIT_INCREMENT = 6

const StemFinder = Component({

  getInitialState: function () {
    let subjectAreaKey = this.props.subjectAreaKey
    let gradeLevelKey = this.props.gradeLevelKey
    let featureTypeKey = this.props.featureTypeKey

    if (!subjectAreaKey && !gradeLevelKey && !featureTypeKey) {
      //
      // If we are not passed props indicating filters to pre-populate
      // then attempt to see if this information is available in the URL.
      //
      const params = this.getFiltersFromURL()
      subjectAreaKey = params.subject
      gradeLevelKey = params['grade-level']
      featureTypeKey = params.feature

      subjectAreaKey = this.mapSubjectArea(subjectAreaKey)
    }

    //
    // Scroll to stem finder if we have filters specified.
    //
    if (subjectAreaKey || gradeLevelKey || featureTypeKey) {
      this.scrollToFinder()
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

    let gradeFiltersSelected = []

    if (gradeLevelKey) {
      let gradeLevels = filters.gradeFilters
      for (i = 0; i < gradeLevels.length; i++) {
        let gradeLevel = gradeLevels[i]
        if (gradeLevel.key === gradeLevelKey) {
          gradeFiltersSelected.push(gradeLevel)
        }
      }
    }

    let featureFiltersSelected = []

    if (featureTypeKey) {
      let featureTypes = filters.featureFilters
      for (i = 0; i < featureTypes.length; i++) {
        let featureType = featureTypes[i]
        if (featureType.key === featureTypeKey) {
          featureFiltersSelected.push(featureType)
        }
      }
    }

    // console.log("INFO stem-finder initial subject areas: ", subjectAreasSelected);

    return {
      opacity: 1,
      subjectAreasSelected: subjectAreasSelected,
      subjectAreasSelectedMap: subjectAreasSelectedMap,
      featureFiltersSelected: featureFiltersSelected,
      gradeFiltersSelected: gradeFiltersSelected,
      resources: [],
      numTotalResources: 0,
      displayLimit: DISPLAY_LIMIT_INCREMENT,
      searchPage: 1,
      firstSearch: true,
      searching: false,
      noResourcesFound: false,
      lastSearchResultCount: 0,
      keyword: '',
      searchInput: ''
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

    // console.log("INFO getFiltersFromURL() found URL parts", parts);

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
      case 'chemistry':
      case 'physics':
        return 'physics-chemistry'
      case 'engineering':
        return 'engineering-tech'
    }
    return subjectArea
  },

  //
  // Scroll to top of stem-finder filter form.
  //
  scrollToFinder: function () {
    let finderFormTop = jQuery('.portal-pages-finder-form').offset().top - 100
    if (jQuery(document).scrollTop() < finderFormTop) {
      jQuery('body, html').animate({ scrollTop: finderFormTop }, 600)
    }
  },

  UNSAFE_componentWillMount: function () {
    waitForAutoShowingLightboxToClose(function () {
      this.search()
    }.bind(this))
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

    let resources = incremental ? this.state.resources.slice(0) : []
    let searchPage = incremental ? this.state.searchPage + 1 : 1

    let keyword = jQuery.trim(this.state.searchInput)
    if (keyword !== '') {
      ga('send', 'event', 'Home Page Search', 'Search', keyword)
    }

    let query = [
      'search_term=',
      encodeURIComponent(keyword),
      '&skip_lightbox_reloads=true',
      '&sort_order=Alphabetical',
      '&include_official=1',
      '&model_types=All',
      '&include_related=2',
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
    ]

    // subject areas
    this.state.subjectAreasSelected.forEach(function (subjectArea) {
      subjectArea.searchAreas.forEach(function (searchArea) {
        query.push('&subject_areas[]=')
        query.push(encodeURIComponent(searchArea))
      })
    })

    // features
    this.state.featureFiltersSelected.forEach(function (featureFilter) {
      if (featureFilter.searchMaterialType) {
        query.push('&material_types[]=')
        query.push(encodeURIComponent(featureFilter.searchMaterialType))
      }
      if (featureFilter.searchMaterialProperty) {
        query.push('&material_properties[]=')
        query.push(encodeURIComponent(featureFilter.searchMaterialProperty))
      }
      if (featureFilter.searchSensors) {
        featureFilter.searchSensors.forEach(function (searchSensor) {
          query.push('&sensors[]=')
          query.push(encodeURIComponent(searchSensor))
        })
      }
      // TODO: model
    })

    // grade
    this.state.gradeFiltersSelected.forEach(function (gradeFilter) {
      if (gradeFilter.searchGroups) {
        gradeFilter.searchGroups.forEach(function (searchGroup) {
          query.push('&grade_level_groups[]=')
          query.push(encodeURIComponent(searchGroup))
        })
      }
      // TODO: informal learning?
    })

    this.setState({
      keyword,
      searching: true,
      noResourcesFound: false,
      resources: resources
    })

    jQuery.ajax({
      url: Portal.API_V1.SEARCH,
      data: query.join(''),
      dataType: 'json'
    }).done(function (result) {
      let numTotalResources = 0
      const results = result.results
      let lastSearchResultCount = 0

      results.forEach(function (result) {
        result.materials.forEach(function (material) {
          portalObjectHelpers.processResource(material)
          resources.push(material)
          lastSearchResultCount++
        })
        numTotalResources += result.pagination.total_items
      })

      resources.sort(sortByName)

      if (this.state.firstSearch) {
        fadeIn(this, 1000)
      }

      this.setState({
        firstSearch: false,
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

  renderLogo: function (subjectArea) {
    // console.log("INFO renderLogo", subjectArea);

    let className = 'portal-pages-finder-form-subject-areas-logo col-2'

    var selected = this.state.subjectAreasSelectedMap[subjectArea.key]
    if (selected) {
      className += ' selected'
    }

    const clicked = function () {
      this.scrollToFinder()

      const subjectAreasSelected = this.state.subjectAreasSelected.slice()
      const subjectAreasSelectedMap = this.state.subjectAreasSelectedMap

      const index = subjectAreasSelected.indexOf(subjectArea)

      if (index === -1) {
        subjectAreasSelectedMap[subjectArea.key] = subjectArea
        subjectAreasSelected.push(subjectArea)
        jQuery('#' + subjectArea.key).addClass('selected')
        ga('send', 'event', 'Home Page Filter', 'Click', subjectArea.title)
      } else {
        subjectAreasSelectedMap[subjectArea.key] = undefined
        subjectAreasSelected.splice(index, 1)
        jQuery('#' + subjectArea.key).removeClass('selected')
      }
      // console.log("INFO subject areas", subjectAreasSelected);
      this.setState({ subjectAreasSelected: subjectAreasSelected, subjectAreasSelectedMap: subjectAreasSelectedMap }, this.search)
    }.bind(this)

    return (
      <div key={subjectArea.key} id={subjectArea.key} className={className} onClick={clicked}>
        <div className={'portal-pages-finder-form-subject-areas-logo-inner'} />
        <div className={'portal-pages-finder-form-subject-areas-logo-label'}>
          {subjectArea.title}
        </div>
      </div>
    )
  },

  renderSubjectAreas: function () {
    return (
      <div className={'portal-pages-finder-form-subject-areas col-12'}>
        <div className={'col-1 spacer'} />
        {filters.subjectAreas.map(function (subjectArea) {
          // console.log("INFO renderSubjectAreas, selected subjects:", this.state.subjectAreasSelected);
          return this.renderLogo(subjectArea)
        }.bind(this))}
      </div>
    )
  },

  clearFilters: function () {
    jQuery('.portal-pages-finder-form-subject-areas-logo').removeClass('selected')
    this.setState({
      subjectAreasSelected: [],
      featureFiltersSelected: [],
      gradeFiltersSelected: [],
      keyword: '',
      searchInput: ''
    }, this.search)
  },

  clearKeyword: function () {
    this.setState({ keyword: '', searchInput: '' }, () => this.search())
  },

  toggleFilter: function (type, filter) {
    const selectedKey = type + 'Selected'
    const selectedFilters = this.state[selectedKey].slice()
    const index = selectedFilters.indexOf(filter)
    if (index === -1) {
      selectedFilters.push(filter)
      jQuery('#' + filter.key).addClass('selected')
      ga('send', 'event', 'Home Page Filter', 'Click', filter.title)
    } else {
      selectedFilters.splice(index, 1)
      jQuery('#' + filter.key).removeClass('selected')
    }
    let state = {}
    state[selectedKey] = selectedFilters
    this.setState(state, this.search)
  },

  renderFilters: function (type, title) {
    return (
      <div className={'portal-pages-finder-form-filters col-3'}>
        <div className={'portal-pages-finder-form-filters-title'}>
          {title}
        </div>
        <div className={'portal-pages-finder-form-filters-options'}>
          {filters[type].map(function (filter) {
            const selectedKey = type + 'Selected'
            const handleChange = function () {
              this.scrollToFinder()
              this.toggleFilter(type, filter)
            }.bind(this)
            const checked = this.state[selectedKey].indexOf(filter) !== -1
            return (
              <div key={filter.key} className={'portal-pages-finder-form-filters-option'}>
                <input type={'checkbox'} id={filter.key} name={filter.key} onChange={handleChange} checked={checked} />
                <label htmlFor={filter.key}>
                  {filter.title}
                </label>
              </div>
            )
          }.bind(this))}
        </div>
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
  },

  handleAutoSuggestSubmit () {
    this.search()
    this.scrollToFinder()
  },

  renderSearch: function () {
    return (
      <div className={'portal-pages-finder-form-search col-4'}>
        <form onSubmit={this.handleSearchSubmit}>
          <div className={'portal-pages-finder-form-search-title'}>
            <label htmlFor={'search-terms'}>
              Search by keyword
            </label>
          </div>
          <div className={'portal-pages-search-input-container'}>
            <AutoSuggest name={'search-terms'} query={this.state.searchInput} onChange={this.handleSearchInputChange} onSubmit={this.handleAutoSuggestSubmit} placeholder={'Type search term here'} />
            <a href={'/search'}>
              Advanced Search
            </a>
          </div>
        </form>
      </div>
    )
  },

  renderForm: function () {
    return (
      <div className={'portal-pages-finder-form'}>
        <div className={'portal-pages-finder-form-inner cols'} style={{ opacity: this.state.opacity }}>
          {this.renderSubjectAreas()}
          <div className={'col-1 spacer'} />
          <div className={'mobile-filter-toggle'}>
            More Filters
          </div>
          {this.renderFilters('featureFilters', 'Filter by Type')}
          {this.renderFilters('gradeFilters', 'Filter by Grade')}
          {this.renderSearch()}
        </div>
      </div>
    )
  },

  renderResultsHeaderFilters: function () {
    const keyword = jQuery.trim(this.state.keyword)
    if (keyword.length + this.state.subjectAreasSelected.length + this.state.featureFiltersSelected.length + this.state.gradeFiltersSelected.length === 0) {
      return null
    }

    let filters = []
    this.state.subjectAreasSelected.forEach(function (subjectArea) {
      filters.push(HeaderFilter({ key: subjectArea.key, type: 'subjectAreas', filter: subjectArea, toggleFilter: this.toggleFilter }))
    }.bind(this))
    this.state.featureFiltersSelected.forEach(function (featureFilter) {
      filters.push(HeaderFilter({ key: featureFilter.key, type: 'featureFilters', filter: featureFilter, toggleFilter: this.toggleFilter }))
    }.bind(this))
    this.state.gradeFiltersSelected.forEach(function (gradeFilter) {
      filters.push(HeaderFilter({ key: gradeFilter.key, type: 'gradeFilters', filter: gradeFilter, toggleFilter: this.toggleFilter }))
    }.bind(this))

    if (keyword.length > 0) {
      filters.push(
        <div key={'keyword'} className={'portal-pages-finder-header-filter'}>
          {'Keyword: ' + keyword}
          <span onClick={this.clearKeyword} />
        </div>
      )
    }

    filters.push(
      <div key={'clear'} className={'portal-pages-finder-header-filters-clear'} onClick={this.clearFilters}>
        Clear Filters
      </div>
    )

    return (
      <div className={'portal-pages-finder-header-filters'}>
        {filters}
      </div>
    )
  },

  renderResultsHeader: function () {
    if (this.state.noResourcesFound || this.state.searching) {
      return (
        <div className={'portal-pages-finder-header'}>
          <div className={'portal-pages-finder-header-resource-count'}>
            {this.state.noResourcesFound ? 'No Resources Found' : 'Searching...'}
          </div>
          {this.renderResultsHeaderFilters()}
        </div>
      )
    }

    const showingAll = this.state.displayLimit >= this.state.numTotalResources
    const multipleResources = this.state.numTotalResources > 1
    const resourceCount = showingAll ? this.state.numTotalResources : this.state.displayLimit + ' of ' + this.state.numTotalResources
    jQuery('#portal-pages-finder').removeClass('loading')
    return (
      <div className={'portal-pages-finder-header'}>
        <div className={'portal-pages-finder-header-resource-count'}>
          {showingAll && multipleResources ? 'Showing All ' : 'Showing '}
          <strong>
            {resourceCount + ' ' + pluralize(resourceCount, 'Resource')}
          </strong>
        </div>
        {this.renderResultsHeaderFilters()}
      </div>
    )
  },

  renderLoadMore: function () {
    const handleLoadAll = function () {
      if (!this.state.searching) {
        this.search(true)
      }
      ga('send', 'event', 'Load More Button', 'Click', this.state.displayLimit + ' resources displayed')
    }.bind(this)
    if ((this.state.resources.length === 0) || (this.state.displayLimit >= this.state.numTotalResources)) {
      return null
    }
    return (
      <div className={'portal-pages-finder-load-all col-6 center'} onClick={handleLoadAll}>
        <button>
          {this.state.searching ? 'Loading...' : 'Load More'}
        </button>
      </div>
    )
  },

  renderResults: function () {
    if (this.state.firstSearch) {
      return null
    }
    const resources = this.state.resources.slice(0, this.state.displayLimit)
    return (
      <div className={'portal-pages-finder-results-inner'}>
        {this.renderResultsHeader()}
        <div className={'portal-pages-finder-results-cards'}>
          {resources.map(function (resource, index) {
            return StemFinderResult({ key: index, resource: resource })
          })}
        </div>
        {this.renderLoadMore()}
      </div>
    )
  },

  render: function () {
    // console.log("INFO stem-finder render()");
    return (
      <div>
        {this.renderForm()}
        <div className={'portal-pages-finder-results cols'} style={{ opacity: this.state.opacity }}>
          {this.renderResults()}
        </div>
      </div>
    )
  }
})

export default StemFinder
