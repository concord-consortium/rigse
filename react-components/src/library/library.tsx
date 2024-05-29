import React, { createElement } from "react";
import ReactDOM from "react-dom/client";

import CollectionsPage from "./components/collections-page";
import CollectionCards from "./components/collection-cards";
import HeaderFilter from "./components/header-filter";
import ResourceLightbox from "./components/resource-lightbox";
import ResourceFinderLightbox from "./components/resource-finder-lightbox";
import StemFinderResult from "./components/stem-finder-result";
import StemFinder from "./components/stem-finder";
import PageHeader from "./components/page-header";
import PageFooter from "./components/page-footer";
import MaterialsCollection from "./components/materials-collection";
import GradeLevels from "./components/grade-levels";
import Tooltip from "./components/tooltip";
import ParseQueryString from "./helpers/parse-query-string";
import { MakeTeacherEditionLinks } from "./helpers/make-teacher-edition-links";
import * as signupFunctions from "./components/signup/signup_functions";
import RecentActivity from "./components/recent-activity";
import Assignments from "./components/assigments";
import PermissionFormsV2 from "./components/permission-forms-v2";
import Navigation from "./components/navigation";
import RunWithCollaborators from "./components/run-with-collaborators";
import LearnerReportForm from "./components/learner-report-form";
import UserReportForm from "./components/user-report-form";
import ResearcherClassesForm from "./components/researcher-classes-form";
import SiteNotices from "./components/site-notices";
import SiteNoticesNewForm from "./components/site-notices/new";
import SiteNoticesEditForm from "./components/site-notices/edit";
import ShowSiteNotices from "./components/site-notices/show";
import FeaturedMaterials from "./components/featured-materials/featured-materials";
import SearchResults from "./components/search/results";
import SMaterialsList from "./components/search/materials-list";
import MaterialsBin from "./components/materials-bin/materials-bin";
import openAssignToClassModal from "./components/assign-to-class/assign-to-class";
import PortalClassSetupForm from "./components/portal-classes/setup-form";
import EditBookmarks from "./components/bookmarks/edit";
import ManageClasses from "./components/portal-classes/manage-classes";
import EditMaterialsCollectionList from "./components/materials-collection/edit-list";
import JoinClass from "./components/portal-students/join-class";
import StudentRoster from "./components/portal-classes/student-roster";
import AutoSuggest from "./components/search/auto-suggest";
import StandardsTable from "./components/standards/standards-table";
import StemFinderResultStandards from "./components/stem-finder-result-standards";
import BrowsePage from "./components/browse-page/browse-page";
import ResourceRequirements from "./components/browse-page/resource-requirements";
import ResourceLicense from "./components/browse-page/resource-license";
import ResourceProjects from "./components/browse-page/resource-projects";
import showTab from "./helpers/tabs";
import { loadMaterialsCollections } from "./helpers/materials-collection-cache";
import { render } from "./helpers/react-render";

import "./library.scss";

declare global {
  const Portal: any;
  const PortalComponents: any;
  const gtag: any;

  interface Window {
    React: any;
    ReactDOM: any;
    Portal: any;
    loadAppliedStandards: any;
    updateSearchUrl: any;
    PortalPages: any;
    PortalComponents: any;
    gtag: any;
    toggleDetails: (jqueryElement: any) => void; // defined in search_materials_expand.js
    hideSharelinks: () => void; // defined in share_material.js
    initTinyMCE: () => void; // defined in tiny_mce_helper.rb
    searchASN: () => void; // defined in _standards_edit.html.haml
  }
}

// previously React and ReactDOM were set by the react-rails gem
window.React = React;
window.ReactDOM = ReactDOM;

const renderComponentFn = function (ComponentClass: any) {
  return function (options: any, id: any) {
    render(ComponentClass(options), id);
  };
};

// to ease the transition from portal-pages maintain both namespaces
window.PortalPages = window.PortalComponents = {
  settings: {}, // default to empty, used to set flags from portal templates

  // The URL of the page will change as the user opens resource lightboxes. This
  // initialPath provides a way for the code to know the initial page loaded was
  // the STEM Resource Finder, a collection page, or a direct resource url.
  initialPath: window.location.pathname,

  MakeTeacherEditionLinks,
  ParseQueryString,
  render,

  CollectionsPage,
  renderCollectionsPage: renderComponentFn(CollectionsPage),

  PermissionFormsV2,
  renderPermissionFormsV2 (options: any, id: any) {
    render(createElement(PermissionFormsV2, options), id);
  },

  RecentActivity,
  renderRecentActivity (options: any, id: any) {
    render(createElement(RecentActivity, options), id);
  },

  Assignments,
  renderAssignments (options: any, id: any) {
    render(createElement(Assignments, options), id);
  },

  LearnerReportForm,
  renderLearnerReportForm (options: any, id: any) {
    render(createElement(LearnerReportForm, options), id);
  },

  // renderResearcherReportForm was renamed renderLearnerReportForm so to allow
  // independent deploys of the this repo and the portal keep this alias in for now
  // NOTE: this should be removed once the user report work in the portal is in production
  //       and no other code references this export.
  ResearcherReportForm: LearnerReportForm,
  renderResearcherReportForm (options: any, id: any) {
    render(createElement(LearnerReportForm, options), id);
  },

  UserReportForm,
  renderUserReportForm (options: any, id: any) {
    render(createElement(UserReportForm, options), id);
  },

  ResearcherClassesForm,
  renderResearcherClassesForm (options: any, id: any) {
    render(createElement(ResearcherClassesForm, options), id);
  },

  Navigation,
  renderNavigation (options: any, id: any) {
    render(createElement(Navigation, options), id);
  },

  SiteNotices,
  renderSiteNotices (options: any, id: any) {
    render(createElement(SiteNotices, options), id);
  },

  SiteNoticesNewForm,
  renderSiteNoticesNewForm (options: any, id: any) {
    render(createElement(SiteNoticesNewForm, options), id);
  },

  SiteNoticesEditForm,
  renderSiteNoticesEditForm (options: any, id: any) {
    render(createElement(SiteNoticesEditForm, options), id);
  },

  ShowSiteNotices,
  renderShowSiteNotices (options: any, id: any) {
    render(createElement(ShowSiteNotices, options), id);
  },

  CollectionCards,
  renderCollectionCards: renderComponentFn(CollectionCards),

  HeaderFilter,
  renderHeaderFilter: renderComponentFn(HeaderFilter),

  BrowsePage,
  renderBrowsePage: renderComponentFn(BrowsePage),

  ResourceLightbox,
  renderResourceLightbox: renderComponentFn(ResourceLightbox),

  ResourceFinderLightbox,
  renderResourceFinderLightbox: renderComponentFn(ResourceFinderLightbox),

  StemFinderResult,
  renderStemFinderResult: renderComponentFn(StemFinderResult),

  StemFinder,
  renderStemFinder: renderComponentFn(StemFinder),

  PageHeader,
  renderPageHeader: renderComponentFn(PageHeader),

  PageFooter,
  renderPageFooter: renderComponentFn(PageFooter),

  GradeLevels,
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
  renderSignupModal (properties: any) {
    signupFunctions.openSignupModal(properties);
  },
  renderLoginModal (properties: any) {
    signupFunctions.openLoginModal(properties);
  },
  renderForgotPasswordModal (properties: any) {
    signupFunctions.openForgotPasswordModal(properties);
  },
  renderAssignToClassModal (properties: any) {
    openAssignToClassModal(properties);
  },

  //
  // Render a signup form to the specified DOM id.
  //
  // Params
  //    properties  - The properties.   E.g. { oauthProviders: [ ... ] }
  //    id          - The DOM id.       E.g. "#test-embedded-signup-form"
  //
  renderSignupForm: signupFunctions.renderSignupForm,

  MaterialsCollection,

  // this loads a set of materials collections in a single AJAX call and caches them for use
  // in a later call to renderMaterialsCollection
  loadMaterialsCollections (ids: any, callback: any) {
    loadMaterialsCollections(ids, callback);
  },

  // this is a different format to match to existing project pages which had 2 formats itself
  renderMaterialsCollection (collectionId: any, selectorOrElement: any, limitOrOptions: any) {
    let options = limitOrOptions || {};
    if (typeof limitOrOptions === "number") {
      options = { limit: limitOrOptions };
    }
    options.collection = collectionId;
    render(MaterialsCollection(options), jQuery(selectorOrElement)[0]);
  },

  Tooltip,
  renderTooltip: renderComponentFn(Tooltip),

  RunWithCollaborators,
  renderRunWithCollaborators: renderComponentFn(RunWithCollaborators),

  FeaturedMaterials,
  renderFeaturedMaterials (selectorOrElement: any) {
    let query = window.location.search;
    if (query[0] === "?") {
      query = query.slice(1);
    }
    render(createElement(FeaturedMaterials, { queryString: query }), jQuery(selectorOrElement)[0]);
  },

  SearchResults,
  renderSearchResults (results: any, selectorOrElement: any) {
    const element = jQuery(selectorOrElement)[0];
    render(createElement(SearchResults, { results }), element);
  },
  renderSearchMessage (message: any, selectorOrElement: any) {
    const element = jQuery(selectorOrElement)[0];
    render(<span>{ message }</span>, element);
  },

  SMaterialsList,
  renderMaterialsList (materials: any, selectorOrElement: any) {
    render(createElement(SMaterialsList, { materials }), jQuery(selectorOrElement)[0]);
  },

  MaterialsBin,
  renderMaterialsBin (definition: any, selectorOrElement: any, queryString: any = null) {
    if (queryString === null) {
      queryString = window.location.search;
    }
    const matches = queryString.match(/assign_to_class=(\d+)/);
    const assignToSpecificClass = matches ? matches[1] : null;
    render(createElement(MaterialsBin, { materials: definition, assignToSpecificClass }), jQuery(selectorOrElement)[0]);
  },

  PortalClassSetupForm,
  renderPortalClassSetupForm (options: any, id: any) {
    render(createElement(PortalClassSetupForm, options), id);
  },

  EditBookmarks,
  renderEditBookmarks (options: any, id: any) {
    render(createElement(EditBookmarks, options), id);
  },

  ManageClasses,
  renderManageClasses (options: any, id: any) {
    render(createElement(ManageClasses, options), id);
  },

  EditMaterialsCollectionList,
  renderEditMaterialsCollectionList (options: any, id: any) {
    render(createElement(EditMaterialsCollectionList, options), id);
  },

  JoinClass,
  renderJoinClass (options: any, id: any) {
    render(createElement(JoinClass, options), id);
  },

  StudentRoster,
  renderStudentRoster (options: any, id: any) {
    render(createElement(StudentRoster, options), id);
  },

  AutoSuggest,
  renderAutoSuggest (options: any, id: any) {
    render(createElement(AutoSuggest, options), id);
  },

  StandardsTable,
  renderStandardsTable (options: any, id: any) {
    render(createElement(StandardsTable, options), id);
  },

  StemFinderResultStandards,
  renderStemFinderResultStandards (options: any, id: any) {
    render(createElement(StemFinderResultStandards, options), id);
  },

  ResourceRequirements,
  renderResourceRequirements (options: any, id: any) {
    render(createElement(ResourceRequirements, options), id);
  },

  ResourceLicense,
  renderResourceLicense (options: any, id: any) {
    render(createElement(ResourceLicense, options), id);
  },

  ResourceProjects,
  renderResourceProjects (options: any, id: any) {
    render(createElement(ResourceProjects, options), id);
  },

  showTab
};
