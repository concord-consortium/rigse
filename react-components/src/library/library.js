import React from 'react'
import ReactDOM from 'react-dom'

import './library.scss'
import CollectionsPage from './components/collections-page'
import CollectionCards from './components/collection-cards'
import HeaderFilter from './components/header-filter'
import ResourceLightbox from './components/resource-lightbox'
import StemFinderResult from './components/stem-finder-result'
import StemFinder from './components/stem-finder'
import PageHeader from './components/page-header'
import PageFooter from './components/page-footer'
import MaterialsCollection from './components/materials-collection'
import GradeLevels from './components/grade-levels'
import Tooltip from './components/tooltip.js'
import ParseQueryString from './helpers/parse-query-string'
import { MakeTeacherEditionLinks } from './helpers/make-teacher-edition-links'
import * as signupFunctions from './components/signup/signup_functions'
import RecentActivity from './components/recent-activity'
import Assignments from './components/assigments'
import Navigation from './components/navigation'
import UnitTestExample from './components/unit-test-example'
import RunWithCollaborators from './components/run-with-collaborators'
import LearnerReportForm from './components/learner-report-form'
import UserReportForm from './components/user-report-form'
import SiteNotices from './components/site-notices'
import SiteNoticesNewForm from './components/site-notices/new'
import SiteNoticesEditForm from './components/site-notices/edit'
import ShowSiteNotices from './components/site-notices/show'
import FeaturedMaterials from './components/featured-materials/featured-materials'
import SearchResults from './components/search/results'
import SMaterialsList from './components/search/materials-list'
import MaterialsBin from './components/materials-bin/materials-bin'
import openAssignToClassModal from './components/assign-to-class/assign-to-class'
import PortalClassSetupForm from './components/portal-classes/setup-form'
import EditBookmarks from './components/bookmarks/edit'
import ManageClasses from './components/portal-classes/manage-classes'
import EditMaterialsCollectionList from './components/materials-collection/edit-list'
import JoinClass from './components/portal-students/join-class'
import StandardsTable from './components/standards/standards-table'

// previously React and ReactDOM were set by the react-rails gem
window.React = React
window.ReactDOM = ReactDOM

const render = function (component, id) {
  ReactDOM.render(component, document.getElementById(id))
}

const renderComponentFn = function (ComponentClass) {
  return function (options, id) {
    render(ComponentClass(options), id)
  }
}

// to ease the transition from portal-pages maintain both namespaces
window.PortalPages =
window.PortalComponents = {
  settings: {}, // default to empty, used to set flags from portal templates

  // The URL of the page will change as the user opens resource lightboxes. This
  // initialPath provides a way for the code to know the initial page loaded was
  // the STEM Resource Finder, a collection page, or a direct resource url.
  initialPath: window.location.pathname,

  MakeTeacherEditionLinks: MakeTeacherEditionLinks,
  ParseQueryString: ParseQueryString,
  render: render,

  CollectionsPage: CollectionsPage,
  renderCollectionsPage: renderComponentFn(CollectionsPage),

  RecentActivity: RecentActivity,
  renderRecentActivity: function (options, id) {
    render(React.createElement(RecentActivity, options), id)
  },

  Assignments: Assignments,
  renderAssignments: function (options, id) {
    render(React.createElement(Assignments, options), id)
  },

  LearnerReportForm: LearnerReportForm,
  renderLearnerReportForm: function (options, id) {
    render(React.createElement(LearnerReportForm, options), id)
  },

  // renderResearcherReportForm was renamed renderLearnerReportForm so to allow
  // independent deploys of the this repo and the portal keep this alias in for now
  // NOTE: this should be removed once the user report work in the portal is in production
  //       and no other code references this export.
  ResearcherReportForm: LearnerReportForm,
  renderResearcherReportForm: function (options, id) {
    render(React.createElement(LearnerReportForm, options), id)
  },

  UserReportForm: UserReportForm,
  renderUserReportForm: function (options, id) {
    render(React.createElement(UserReportForm, options), id)
  },

  Navigation: Navigation,
  renderNavigation: function (options, id) {
    render(React.createElement(Navigation, options), id)
  },

  UnitTestExample: UnitTestExample,
  renderUnitTestExample: function (options, id) {
    render(React.createElement(UnitTestExample, options), id)
  },

  SiteNotices: SiteNotices,
  renderSiteNotices: function (options, id) {
    render(React.createElement(SiteNotices, options), id)
  },

  SiteNoticesNewForm: SiteNoticesNewForm,
  renderSiteNoticesNewForm: function (options, id) {
    render(React.createElement(SiteNoticesNewForm, options), id)
  },

  SiteNoticesEditForm: SiteNoticesEditForm,
  renderSiteNoticesEditForm: function (options, id) {
    render(React.createElement(SiteNoticesEditForm, options), id)
  },

  ShowSiteNotices: ShowSiteNotices,
  renderShowSiteNotices: function (options, id) {
    render(React.createElement(ShowSiteNotices, options), id)
  },

  CollectionCards: CollectionCards,
  renderCollectionCards: renderComponentFn(CollectionCards),

  HeaderFilter: HeaderFilter,
  renderHeaderFilter: renderComponentFn(HeaderFilter),

  ResourceLightbox: ResourceLightbox,
  renderResourceLightbox: renderComponentFn(ResourceLightbox),

  StemFinderResult: StemFinderResult,
  renderStemFinderResult: renderComponentFn(StemFinderResult),

  StemFinder: StemFinder,
  renderStemFinder: renderComponentFn(StemFinder),

  PageHeader: PageHeader,
  renderPageHeader: renderComponentFn(PageHeader),

  PageFooter: PageFooter,
  renderPageFooter: renderComponentFn(PageFooter),

  GradeLevels: GradeLevels,
  renderGradeLevels: renderComponentFn(GradeLevels),

  //
  // Render modal popups for login and signup.
  // Unlike other PortalComponents methods, these methods do not take a
  // DOM id as parameter. A DOM element will be dynamically generated
  // for these method.
  //
  // Params
  //    properties  - A properties object. E.g. { oauthProviders: [ ... ] }
  //
  renderSignupModal: function (properties) {
    signupFunctions.openSignupModal(properties)
  },
  renderLoginModal: function (properties) {
    signupFunctions.openLoginModal(properties)
  },
  renderForgotPasswordModal: function (properties) {
    signupFunctions.openForgotPasswordModal(properties)
  },
  renderAssignToClassModal: function (properties) {
    openAssignToClassModal(properties)
  },

  //
  // Render a signup form to the specified DOM id.
  //
  // Params
  //    properties  - The properties.   E.g. { oauthProviders: [ ... ] }
  //    id          - The DOM id.       E.g. "#test-embedded-signup-form"
  //
  renderSignupForm: signupFunctions.renderSignupForm,

  MaterialsCollection: MaterialsCollection,
  // this is a different format to match to existing project pages which had 2 formats itself
  renderMaterialsCollection: function (collectionId, selectorOrElement, limitOrOptions) {
    let options = limitOrOptions || {}
    if (typeof limitOrOptions === 'number') {
      options = { limit: limitOrOptions }
    }
    options.collection = collectionId
    ReactDOM.render(MaterialsCollection(options), jQuery(selectorOrElement)[0])
  },

  Tooltip: Tooltip,
  renderTooltip: renderComponentFn(Tooltip),

  RunWithCollaborators: RunWithCollaborators,
  renderRunWithCollaborators: renderComponentFn(RunWithCollaborators),

  FeaturedMaterials: FeaturedMaterials,
  renderFeaturedMaterials: function (selectorOrElement) {
    let query = window.location.search
    if (query[0] === '?') {
      query = query.slice(1)
    }
    ReactDOM.render(React.createElement(FeaturedMaterials, { queryString: query }), jQuery(selectorOrElement)[0])
  },

  // NOTE: the search results renders re-render into the same div so it is required to call unmountComponentAtNode
  //       (as these methods do) before each re-render to avoid a warning message and a potential memory leak
  SearchResults: SearchResults,
  renderSearchResults: function (results, selectorOrElement) {
    const element = jQuery(selectorOrElement)[0]
    ReactDOM.unmountComponentAtNode(element)
    ReactDOM.render(React.createElement(SearchResults, { results }), element)
  },
  renderSearchMessage: function (message, selectorOrElement) {
    const element = jQuery(selectorOrElement)[0]
    ReactDOM.unmountComponentAtNode(element)
    ReactDOM.render(<span>{message}</span>, element)
  },

  SMaterialsList: SMaterialsList,
  renderMaterialsList: function (materials, selectorOrElement) {
    ReactDOM.render(React.createElement(SMaterialsList, { materials }), jQuery(selectorOrElement)[0])
  },

  MaterialsBin: MaterialsBin,
  renderMaterialsBin: function (definition, selectorOrElement, queryString = null) {
    if (queryString === null) {
      queryString = window.location.search
    }
    const matches = queryString.match(/assign_to_class=(\d+)/)
    const assignToSpecificClass = matches ? matches[1] : null
    ReactDOM.render(React.createElement(MaterialsBin, { materials: definition, assignToSpecificClass }), jQuery(selectorOrElement)[0])
  },

  PortalClassSetupForm: PortalClassSetupForm,
  renderPortalClassSetupForm: function (options, id) {
    render(React.createElement(PortalClassSetupForm, options), id)
  },

  EditBookmarks: EditBookmarks,
  renderEditBookmarks: function (options, id) {
    render(React.createElement(EditBookmarks, options), id)
  },

  ManageClasses: ManageClasses,
  renderManageClasses: function (options, id) {
    render(React.createElement(ManageClasses, options), id)
  },

  EditMaterialsCollectionList: EditMaterialsCollectionList,
  renderEditMaterialsCollectionList: function (options, id) {
    render(React.createElement(EditMaterialsCollectionList, options), id)
  },

  JoinClass: JoinClass,
  renderJoinClass: function (options, id) {
    render(React.createElement(JoinClass, options), id)
  },

  StandardsTable: StandardsTable,
  renderStandardsTable: function (options, id) {
    render(React.createElement(StandardsTable, options), id)
  }
}
