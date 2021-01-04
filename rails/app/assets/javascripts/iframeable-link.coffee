do ->
  $ = jQuery

  class IframeableLink
    IFRAME_CLASS = 'external-link-iframe'

    constructor: (element) ->
      @$element = $(element)
      @iframeSrc = @$element.data('iframe-src')

      @iframeVisible = false
      @$iframe = $('<iframe>')
        .addClass(IFRAME_CLASS)
        .css({
          # Note that this is only a suggestion, max width and height are defined in CSS!
          width: @$element.data('iframe-width'),
          height: @$element.data('iframe-height'),
          display: 'none'
        })
        .appendTo @$element.parent()

      @$element.on 'click', (e) =>
        @iframeVisible = !@iframeVisible
        @setIframeSrc()
        @updateView()
        e.preventDefault()

    setIframeSrc: ->
      # Set iframe src (== load iframe) only when link is clicked for the frist time.
      currentSrc = @$iframe.attr('src')
      if currentSrc != @iframeSrc
        @$iframe.attr('src', @iframeSrc)

    updateView: ->
      if @iframeVisible
        @$iframe.fadeIn()
        @$element.text('Hide work')
      else
        @$iframe.fadeOut()
        @$element.text('View work')


  $(document).ready ->
    $('.iframeable-link').each ->
      new IframeableLink(this)
