{div} = React.DOM

window.SPaginationClass = React.createClass
  componentDidMount: ->
    return if @props.info.total_pages < 2 # don't display pagination if there's only 1 page
    node = jQuery(React.findDOMNode(@))
    node.paging @props.info.total_items,
      format: '<  . (qq -) nnncnnn (- pp) >'
      perpage: @props.info.per_page
      lapping: 0
      page: @props.info.current_page
      onSelect: @props.onSelect
      onFormat: (type)->
        switch type
          when 'block'
            if !@active
              return "<span class='disabled'>#{@value}</span>"
            else if @value != @page
              return "<em><a href='javascript:void(0)' class='page'>#{@value}</a></em>"
            return "<span class='current page'>#{@value}</span>"

          when 'next'
            if @active
              return "<a href='javascript:void(0)' class='next'>Next →</a>"
            return '<span class="disabled">Next →</span>'

          when 'prev'
            if @active
              return "<a href='javascript:void(0)' class='prev'>← Previous</a>"
            return '<span class="disabled">← Previous</span>'

          when 'first'
            if @active
              return "<a href='javascript:void(0)' class='first'>|&lt;</a>"
            return '<span class="disabled">|&lt;</span>'

          when 'last'
            if @active
              return"<a href='javascript:void(0)' class='last'>&gt;|</a>"
            return '<span class="disabled">&gt;|</span>'

          when "leap"
            return if @active then "   " else ''
          when 'fill'
            return if @active then "..." else ""
          else
            return ""

  shouldComponentUpdate: -> false

  render: ->
    (div {className: 'pagination'})

window.SPagination = React.createFactory SPaginationClass

