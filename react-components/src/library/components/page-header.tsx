import React from 'react'
import Component from '../helpers/component'

import fadeIn from '../helpers/fade-in'
import Tooltip from '../helpers/tooltip'
import ItemTooltip from './tooltip'
import SitewideAlert from './sitewide-alert'

const PageHeader = Component({

  getInitialState: function () {
    return {
      windowWidth: window.innerWidth,
      nav_menu_collapsed: true,
            loggedIn: Portal.currentUser.isLoggedIn,
      opacity: 0,
      userId: 0,
      logo_class: 'concord-logo ' + this.props.logo_class,
            oauthProviders: this.props.oauthProviders || Portal.oauthProviders || {},
            theme: this.props.theme || Portal.theme || 'default',
            homePath: this.props.homePath || Portal.currentUser.homePath || '/',
            isStudent: this.props.isStudent || Portal.currentUser.isStudent || false,
      sitewideAlert: this.props.sitewideAlert
    }
  },

  componentDidMount: function () {
    window.addEventListener('resize', this.handleResize)
    if (this.state.loggedIn) {
      let self = this
      jQuery.ajax({
        url: '/auth/user', // TODO: replace with Portal.API_V1 constant when available
        dataType: 'json'
      }).done(function (data: any) {
        self.setState({ userId: data.id })
        // @ts-expect-error TS(2554): Expected 1 arguments, but got 2.
        fadeIn(this, 1000)
      }.bind(this))
    } else {
      // @ts-expect-error TS(2554): Expected 1 arguments, but got 2.
      fadeIn(this, 1000)
    }
  },

  handleResize: function (e: any) {
    this.setState({ windowWidth: window.innerWidth })
  },

  handleLoginButton: function (e: any) {
    e.preventDefault()
    console.log('INFO calling renderLoginModal()')
        PortalComponents.renderLoginModal(
      {
        oauthProviders: this.state.oauthProviders,
        afterSigninPath: this.props.afterSigninPath
      })
        gtag('event', 'click', {
      'category': 'User Authentication',
      'label': 'User login button clicked'
    })
  },

  handleRegisterButton: function (e: any) {
    e.preventDefault()
        PortalComponents.renderSignupModal(
      { oauthProviders: this.state.oauthProviders, closeable: true },
      'signup-default-modal'
    )
        gtag('event', 'click', {
      'category': 'User Registration',
      'label': 'User register button clicked'
    })
  },

  handleNavMenuToggle: function (e: any) {
    let collapsed = !this.state.nav_menu_collapsed
    this.setState({ nav_menu_collapsed: collapsed })
    if (collapsed) {
      jQuery('body').attr('data-mobile-nav', 'closed')
    } else {
      jQuery('body').attr('data-mobile-nav', 'open')
    }
  },

  toggleTooltip: function (e: any) {
    e.preventDefault()
    e.stopPropagation()

    let tooltip = !this.state.tooltip

    this.setState({
      tooltip: tooltip
    })

    // mount/unmount tooltip outside of homepage content
    if (tooltip) {
      let ProtectedLinkTooltip = ItemTooltip({
        id: e.target.id + '-tooltip',
        text: e.target.title,
        posx: e.pageX + 30,
        posy: e.pageY + jQuery('#' + e.target.id).height() + 3,
        type: 'under',
        close_delay: 5000,
        toggleTooltip: this.toggleTooltip
      })
      Tooltip.open(ProtectedLinkTooltip)
    } else {
      Tooltip.close()
    }
  },

  renderFirstButton: function () {
    if (this.state.loggedIn) {
      return (
        <a href={this.state.homePath} title='View Recent Activity' className='portal-pages-main-nav-item__link button register'><i className='icon-home' />My Classes</a>
      )
    } else {
      return (
        <a href='/signup' title='Create an Account' className='portal-pages-main-nav-item__link button register' onClick={this.handleRegisterButton}>Register</a>
      )
    }
  },

  renderSecondButton: function () {
    if (this.state.loggedIn) {
      return (
        <a href='/users/sign_out' title='Log Out' className='portal-pages-main-nav-item__link button log-in'><i className='icon-login' />Log Out</a>
      )
    } else {
      return (
        <a href='/users/sign_in' title='Log In' className='portal-pages-main-nav-item__link button log-in' onClick={this.handleLoginButton}><i className='icon-login' />Log In</a>
      )
    }
  },

  renderProtectedLink: function (linkID: any, linkTitle: any, linkText: any) {
    return (
      <a href='#' className={'portal-pages-main-nav-item__link'} id={linkID} title={linkTitle} onClick={this.toggleTooltip}>{linkText}</a>
    )
  },

  renderNavLinks: function (e: any) {
    var headerItems = []
    var key = 1
    var nextKey = (prefix: any) => `navLink_${prefix}_${key++}`
    if (!this.state.isStudent) {
      if (this.state.theme === 'ngss-assessment') {
        headerItems.push(
          <li key={nextKey('AssessmentTasks')} className={'portal-pages-main-nav-item has-drop-down' + ' portal-pages-main-nav-collections' + (this.props.isCollections ? ' current-menu-item' : '')}>
            <a href='/about' className='portal-pages-main-nav-item__link'>Assessment Tasks</a>
            <ul className='portal-pages-main-nav-dropdown'>
              <li className='portal-pages-main-nav-dropdown__item'><a className='portal-pages-main-nav-dropdown__item-link' href='/elementary-school'>Elementary Grades (3-5) Tasks</a></li>
              <li className='portal-pages-main-nav-dropdown__item'><a className='portal-pages-main-nav-dropdown__item-link' href='/middle-school'>Middle Grades (6-8) Tasks</a></li>
            </ul>
          </li>
        )
        if (this.state.loggedIn) {
          headerItems.push(
            <li key={nextKey('ForumLoggedIn')} className='portal-pages-main-nav-item portal-pages-main-nav-forum'>
              <a href='https://ngsa.concord.org/forum?autosignin=true' className='portal-pages-main-nav-item__link' title='Visit the NGSA Forum'>Forum</a>
            </li>
          )
        } else {
          let linkID = 'ngsa-forum'
          let linkTitle = 'Registered teachers can participate in a forum with other teachers. Login or register as a teacher to access the forum.'
          let linkText = 'Forum'
          headerItems.push(
            <li key={nextKey('ForumLoggedOut')} className='portal-pages-main-nav-item portal-pages-main-nav-forum'>
              {this.renderProtectedLink(linkID, linkTitle, linkText)}
            </li>
          )
        }
      } else {
        headerItems.push(
          <li key={nextKey('Collections')} className={'portal-pages-main-nav-item' + ' portal-pages-main-nav-collections' + (this.props.isCollections ? ' current-menu-item' : '')}>
            <a href='/collections' className='portal-pages-main-nav-item__link' title='View Resource Collections'>Collections</a>
          </li>
        )
        headerItems.push(
          <li key={nextKey('About')} className={'portal-pages-main-nav-item' + ' portal-pages-main-nav-about' + (this.props.isAbout ? ' current-menu-item' : '')}>
            <a href='/about' className='portal-pages-main-nav-item__link' title='Learn More about the STEM Resource Finder'>About</a>
          </li>
        )
      }
    }

    headerItems.push(
      <li key={nextKey('FirstButton')} className='portal-pages-main-nav-item'>
        {this.renderFirstButton()}
      </li>
    )
    headerItems.push(
      <li key={nextKey('SecondButton')} className='portal-pages-main-nav-item'>
        {this.renderSecondButton()}
      </li>
    )

    return (
      <ul className='portal-pages-main-nav-contain'>
        {headerItems}
      </ul>
    )
  },

  renderHeader: function () {
    let wrapperClass = 'theme-' + this.state.theme
    wrapperClass = this.state.loggedIn ? wrapperClass + ' logged-in' : wrapperClass
    let navLinks = ''
    if (this.state.windowWidth > 950 || !this.state.nav_menu_collapsed) {
      navLinks = this.renderNavLinks()
    }
    let logoClass = this.state.logo_class
    let logoText = 'Home'
    const sitewideAlertContent = this.state.sitewideAlert
    const sitewideAlertBanner = sitewideAlertContent ? <SitewideAlert content={sitewideAlertContent} /> : undefined
    return (
      <div className={wrapperClass}>
        <div className='portal-pages-umbrella'>
          <div className='portal-pages-umbrella-contain cols'>
            <div className='portal-pages-concord-link col-12'>
              <a href='https://concord.org/' className='portal-pages-concord-link__item'>Learn about the Concord Consortium <i className='icon-arrow-diagonal' /></a>
            </div>
          </div>
        </div>
        {sitewideAlertBanner}
        <nav className='concord-navigation cols no-collapse'>
          <div className='logo-contain col-3'>
                        <a href={Portal.currentUser.homePath} title='Go to the Home Page'>
              <div className={logoClass}>
                <div className='concord-logo__linktext'>
                  {logoText}
                </div>
              </div>
            </a>
          </div>
          <div className='portal-pages-main-nav col-9'>
            {navLinks}
            <div className='mobile-nav-contain'>
              <div className='mobile-nav-btn'>
                <span className='opener'>Menu</span>
                <span className='closer'>Close</span>
                <div className='mobile-nav-icon' onClick={this.handleNavMenuToggle}>
                  <span />
                  <span />
                  <span />
                </div>
              </div>
            </div>
          </div>
        </nav>
      </div>
    )
  },

  render: function () {
    return this.renderHeader()
  }

})

export default PageHeader
