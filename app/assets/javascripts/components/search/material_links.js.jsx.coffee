window.GenericLinkClass = React.createClass
  wrapOnclick: (str)->
    return ->
      eval(str)

  render: ->
    link = @props.link
    link.className = 'button' unless link.className?
    if typeof link.onclick is 'string'
      link.onclick = @wrapOnclick(link.onclick)
    return `(
      <a href={link.url} className={link.className} target={link.target} onClick={link.onclick} dangerouslySetInnerHTML={{__html: link.text}} />
    )`

window.GenericLink = React.createFactory GenericLinkClass

MaterialLink = React.createClass
  render: ->
    link = @props.link
    return `(
      <div key={link.key} style={{float: 'right', marginRight: '5px'}}><GenericLinkClass link={link} /></div>
    )`

MaterialDropdownLink = React.createClass
  handleClick: (event)->
    console.log(event)
    window.dropevent = jQuery.extend({}, event)
    hideSharelinks()
    if !event.target.nextSibling.visible()
      event.target.nextSibling.show()
      event.target.nextSibling.addClassName('visible')
      event.target.innerHTML = @expandedText

  render: ->
    link = @props.link
    @expandedText = link.expandedText
    options = link.options.map (item)-> `<div className='preview_link'><GenericLinkClass link={item} /></div>`
    link.onclick = @handleClick
    return `(
      <div key={link.key} style={{float: 'right'}}>
        <GenericLinkClass link={link} />
        <div className='Expand_Collapse Expand_Collapse_preview' style={{display: 'none'}}>
          {options}
        </div>
      </div>
    )`

MaterialLinksClass = React.createClass
  render: ->
    links =  @props.links.map (link)->
      if link?
        if link.type is 'dropdown'
          return `<MaterialDropdownLink link={link} />`
        else
          return `<MaterialLink link={link} />`
      else
        return ''

    return `(
      <div>
        {links}
      </div>
    )`

window.MaterialLinks = React.createFactory MaterialLinksClass