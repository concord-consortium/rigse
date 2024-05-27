import React from 'react';
import { render, screen } from '@testing-library/react';
// @ts-expect-error TS(2307): Cannot find module 'components/navigation/index' o... Remove this comment to see the full error message
import Navigation from 'components/navigation/index';
import jQuery from 'jquery';
// @ts-expect-error TS(2339): Property 'jQuery' does not exist on type 'Window &... Remove this comment to see the full error message
window.jQuery = jQuery;

// @ts-expect-error TS(2304): Cannot find name 'global'.
global.Portal = {
  API_V1: {
    EXTERNAL_RESEARCHER_REPORT_LEARNER_QUERY: 'http://query-test.concord.org',
  },
  currentUser: {
    isTeacher: true,
  },
};

const NAV_SPEC = {
  name: 'Harry Potter',
  help: {
    label: 'help',
    url: '#/help',
    id: '/help',
    type: 'LINK',
    popOut: true,
  },
  greeting: 'Hello,',
  selected_section: '__ROOT__',
  request_path: '',
  links: [
    {
      type: 'LINK',
      sort: 5,
      id: '/settings',
      label: 'Settings',
      url: '#/users/3566/preferences',
      iconName: 'icon-settings',
      small: 'true',
    },
    {
      type: 'LINK',
      sort: 5,
      id: '/favorites',
      label: 'Favorites',
      url: '#/users/3566/favorites',
      iconName: 'icon-favorite',
      small: 'true',
    },
    {
      type: 'LINK',
      sort: 5,
      id: '/recent_updates',
      label: 'Recent updates',
      url: '#/recent_activity',
    },
    {
      type: 'SECTION',
      sort: 5,
      id: '/classes',
      label: 'Classes',
      children: [
        {
          type: 'SECTION',
          sort: 5,
          id: '/classes/6846',
          label: 'sample class 26',
          children: [
            {
              type: 'LINK',
              sort: 10,
              id: '/classes/6846/assignments',
              label: 'Assignments',
              url: '#/portal/classes/6846/materials',
            },
            {
              type: 'LINK',
              sort: 5,
              id: '/classes/6846/roster',
              label: 'Student Roster',
              url: '#/portal/classes/6846/roster',
            },
            {
              type: 'LINK',
              sort: 5,
              id: '/classes/6846/setup',
              label: 'Class Setup',
              url: '#/portal/classes/6846/edit',
            },
            {
              type: 'LINK',
              sort: 5,
              id: '/classes/6846/links',
              label: 'Links',
              url: '#/portal/classes/6846/bookmarks',
            },
          ],
        },
        {
          type: 'SECTION',
          sort: 5,
          id: '/classes/6847',
          label: 'sample class 27',
          children: [
            {
              type: 'LINK',
              sort: 5,
              id: '/classes/6847/assignments',
              label: 'Assignments',
              url: '#/portal/classes/6847/materials',
            },
            {
              type: 'LINK',
              sort: 5,
              id: '/classes/6847/roster',
              label: 'Student Roster',
              url: '#/portal/classes/6847/roster',
            },
            {
              type: 'LINK',
              sort: 5,
              id: '/classes/6847/setup',
              label: 'Class Setup',
              url: '#/portal/classes/6847/edit',
            },
            {
              type: 'LINK',
              sort: 5,
              id: '/classes/6847/links',
              label: 'Links',
              url: '#/portal/classes/6847/bookmarks',
            },
          ],
        },
        {
          type: 'SECTION',
          sort: 5,
          id: '/classes/6848',
          label: 'sample class 28',
          children: [
            {
              type: 'LINK',
              sort: 5,
              id: '/classes/6848/assignments',
              label: 'Assignments',
              url: '#/portal/classes/6848/materials',
            },
            {
              type: 'LINK',
              sort: 5,
              id: '/classes/6848/roster',
              label: 'Student Roster',
              url: '#/portal/classes/6848/roster',
            },
            {
              type: 'LINK',
              sort: 5,
              id: '/classes/6848/setup',
              label: 'Class Setup',
              url: '#/portal/classes/6848/edit',
            },
            {
              type: 'LINK',
              sort: 5,
              id: '/classes/6848/links',
              label: 'Links',
              url: '#/portal/classes/6848/bookmarks',
            },
          ],
        },
        {
          type: 'BREAK',
          sort: 5,
          id: '/classes/break',
          label: 'Add Class',
          url: '#/portal/classes/new',
        },
        {
          type: 'LINK',
          sort: 5,
          id: '/classes/add',
          label: 'Add Class',
          url: '#/portal/classes/new',
        },
        {
          type: 'LINK',
          sort: 5,
          id: '/classes/manage',
          label: 'Manage Classes',
          url: '#http://test.host/portal/classes/manage',
        },
      ],
    },
    {
      type: 'SECTION',
      sort: 5,
      id: '/resources',
      label: 'Resources',
      children: [
        {
          type: 'LINK',
          sort: 5,
          id: '/resources/interactives',
          label: 'interactives',
          url: '#/interactives',
          popOut: true,
        },
        {
          type: 'LINK',
          sort: 5,
          id: '/resources/images',
          label: 'images',
          url: '#/images',
          popOut: true,
        },
        {
          type: 'LINK',
          sort: 5,
          id: '/resources/guides',
          label: 'Teacher Guides',
          url: '#https://guides.itsi.concord.org/',
          popOut: true,
        },
        {
          type: 'LINK',
          sort: 5,
          id: '/resources/careers',
          label: 'Careersight',
          url: '#https://careersight.concord.org/',
          popOut: true,
        },
        {
          type: 'LINK',
          sort: 5,
          id: '/resources/probes',
          label: 'Probesight',
          url: '#https://probesight.concord.org/',
          popOut: true,
        },
        {
          type: 'LINK',
          sort: 1,
          id: '/resources/schoology',
          label: 'Schoology',
          url: '#https://www.schoology.com/',
          popOut: true,
        },
      ],
    },
    {
      type: 'LINK',
      sort: 1,
      id: '/activities',
      label: 'Activities',
      url: '#/itsi',
      popOut: false,
    },
  ],
};

const assertLinkOrder = (nav: any, earlier: any, later: any) => {
  let foundFirst = false;
  let foundLast = false;
  let result = false;
  nav.forEach((node: any) => {
    const label = node.textContent;
    if (label.match(later)) {
      foundLast = true;
      result = foundFirst;
    }
    if (label.match(earlier)) {
      foundFirst = true;
      result = !foundLast;
    }
  });
  expect(result).toBeTruthy();
};

describe('When I try to render the navigation', () => {
  beforeEach(() => {
    render(<Navigation {...NAV_SPEC} />);
  });

  it('Displays the users name', () => {
    expect(screen.getByText('Harry Potter')).toBeInTheDocument();
  });

  it('Displays a greeting', () => {
    expect(screen.getByText(/Hello,/)).toBeInTheDocument();
  });

  describe('ordering of links', () => {
    it('Should list activites before resources', () => {
      const navItems = screen.getAllByRole('listitem');
      assertLinkOrder(navItems, 'Classes', 'Resources');
      assertLinkOrder(navItems, 'Activities', 'Resources');
    });
  });
});
