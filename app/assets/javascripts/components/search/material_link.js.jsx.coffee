MaterialLink = React.createClass
  render: ->
    link = @props.link
    return `(
      <div style={{float: 'right'}}><a href={link.url} className={'button'} target={link.target}>{link.text}</a></div>
    )`

MaterialLinks = React.createClass
  render: ->
    links =  @props.links.map (link)->
      return if link? then `<MaterialLink link={link} />` else ''

    return `(
      <div>
        {links}
      </div>
    )`

window.MaterialLink = MaterialLink
window.MaterialLinks = MaterialLinks
