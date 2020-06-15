import React from 'react'

export class SMaterialLinks extends React.Component {
  render () {
    return (
      <div>
        {this.props.links.map((link, idx) => link.type === 'dropdown'
          ? <SMaterialDropdownLink key={idx} link={link} />
          : <SMaterialLink key={idx} link={link} />
        )}
      </div>
    )
  }
}

export class SGenericLink extends React.Component {
  constructor (props) {
    super(props)
    this.wrapOnClick = this.wrapOnClick.bind(this)
  }

  optionallyWrapConfirm (link) {
    if (link.ccConfirm) {
      const followLink = () => {
        window.location = link.url
      }
      link.onclick = function (event) {
        Portal.confirm({
          message: link.ccConfirm,
          callback: followLink
        })
        event.preventDefault()
      }
    }
  }

  wrapOnClick (str) {
    /* eslint no-eval: "off" */
    return () => eval(str)
  }

  render () {
    const { link } = this.props
    this.optionallyWrapConfirm(link)

    if (link.className == null) {
      link.className = 'button'
    }
    if (typeof link.onclick === 'string') {
      link.onclick = this.wrapOnClick(link.onclick)
    }

    // React 16 shows a warning when using javascript:void(0) so replace it with the equivalent
    const url = link.url === 'javascript:void(0)' ? '#' : link.url

    return (
      <a
        href={url}
        className={link.className}
        target={link.target}
        onClick={link.onclick}
        data-cc-confirm={link.ccConfirm}
        dangerouslySetInnerHTML={{ __html: link.text }}
      />
    )
  }
}

export class SMaterialLink extends React.Component {
  render () {
    const { link } = this.props
    return (
      <div key={link.key} style={{ float: 'right', marginRight: '5px' }}>
        <SGenericLink link={link} />
      </div>
    )
  }
}

export class SMaterialDropdownLink extends React.Component {
  constructor (props) {
    super(props)
    this.handleClick = this.handleClick.bind(this)
  }

  handleClick (event) {
    window.hideSharelinks()
    if (!event.target.nextSibling.visible()) {
      event.target.nextSibling.show()
      event.target.nextSibling.addClassName('visible')
      event.target.innerHTML = this.expandedText
    }
  }

  render () {
    const { link } = this.props
    this.expandedText = link.expandedText
    link.onclick = this.handleClick

    return (
      <div key={link.key} style={{ float: 'right' }}>
        <SGenericLink link={link} />
        <div className='Expand_Collapse Expand_Collapse_preview' style={{ display: 'none' }}>
          {link.options.map((item, idx) => (
            <div key={idx} className='preview_link'>
              <SGenericLink link={item} />
            </div>
          ))}
        </div>
      </div>
    )
  }
}
