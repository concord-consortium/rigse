import React from 'react'
import { throttle, debounce } from 'throttle-debounce'

import css from './auto-suggest.scss'

class Suggestion extends React.Component {
  render () {
    const { suggestion, selected } = this.props
    const onClick = () => this.props.onClick(suggestion)
    const className = `${css.suggestion}${selected ? ` ${css.selectedSuggestion}` : ''}`
    return <div className={className} onClick={onClick}>{suggestion}</div>
  }
}

// adapted from https://www.peterbe.com/plog/how-to-throttle-and-debounce-an-autocomplete-input-in-react
export default class AutoSuggest extends React.Component {
  constructor (props) {
    super(props)
    this.state = {
      query: props.query || '',
      suggestions: [],
      selectedSuggestionIndex: -1,
      showSuggestions: false
    }
    this.handleInputChange = this.handleInputChange.bind(this)
    this.handleKeyDown = this.handleKeyDown.bind(this)
    this.handleSuggestionClick = this.handleSuggestionClick.bind(this)
    this.handleOuterClick = this.handleOuterClick.bind(this)

    this.debouncedSearch = debounce(1000, this.search)
    this.throttledSearch = throttle(500, this.search)
    this.currentQuery = ''
    this.queryCache = {}
    this.inputRef = React.createRef()
    this.containerRef = React.createRef()
  }

  // eslint-disable-next-line camelcase
  UNSAFE_componentWillMount () {
    window.addEventListener('click', this.handleOuterClick)
  }

  componentWillUnmount () {
    window.removeEventListener('click', this.handleOuterClick)
  }

  handleOuterClick (e) {
    let el = e.target
    const container = this.containerRef.current
    if (container && this.state.showSuggestions) {
      while (el && (el !== container)) {
        el = el.parentNode
      }
      if (!el) {
        this.setState({ showSuggestions: false })
      }
    }
  }

  // eslint-disable-next-line camelcase
  UNSAFE_componentWillReceiveProps (nextProps) {
    const { query } = nextProps
    // reset and hide the suggestions when the query is cleared
    if ((query !== undefined) && (query.length === 0)) {
      this.setState({ query, suggestions: [], selectedSuggestionIndex: -1, showSuggestions: false })
    }
  }

  search (query) {
    const setSuggestions = (suggestions, callback) => {
      const showSuggestions = suggestions.length > 0
      this.setState({ suggestions, selectedSuggestionIndex: showSuggestions ? 0 : -1, showSuggestions }, callback)
    }
    const trimmedQuery = query.trim()
    this.currentQuery = trimmedQuery
    setSuggestions([], () => {
      if (trimmedQuery.length > 0) {
        if (this.queryCache[trimmedQuery]) {
          setSuggestions(this.queryCache[trimmedQuery])
        } else {
          jQuery.ajax({
            url: '/api/v1/search/search_suggestions',
            data: { search_term: trimmedQuery },
            dataType: 'json',
            success: results => {
              this.queryCache[results.search_term] = results.suggestions
              if (results.search_term === this.currentQuery) {
                setSuggestions(results.suggestions)
              }
            },
            error: () => {
              console.error('GET search suggestions failed')
            }
          })
        }
      }
    })
  }

  userInitiatedSearch (query, onHandler) {
    this.setState({ query }, () => {
      if (onHandler) {
        onHandler(query)
      }
      if ((query.length < 5) || query.endsWith(' ')) {
        this.throttledSearch(query)
      } else {
        this.debouncedSearch(query)
      }
    })
  }

  handleSuggestionClick (query) {
    this.setState({ showSuggestions: false }, () => this.userInitiatedSearch(query, this.props.onSubmit))
  }

  handleInputChange (e) {
    this.userInitiatedSearch(e.target.value, this.props.onChange)
  }

  handleKeyDown (e) {
    let handledKey = false
    const { suggestions, selectedSuggestionIndex, showSuggestions } = this.state

    switch (e.keyCode) {
      case 13: // enter
        if (showSuggestions) {
          const suggestion = suggestions[selectedSuggestionIndex]
          if (suggestion !== undefined) {
            this.setState({ query: suggestion, showSuggestions: false, selectedSuggestionIndex: -1 }, () => {
              const { onChange, onSubmit } = this.props
              if (onChange) {
                onChange(suggestion)
              }
              if (onSubmit) {
                // allow onChange to settle in stem-finder
                setTimeout(() => onSubmit(), 1)
              }
            })
            handledKey = true
          }
        }
        break
      case 27: // escape
        if (showSuggestions) {
          this.setState({ showSuggestions: false, selectedSuggestionIndex: -1 })
          handledKey = true
        }
        break
      case 38: // up arrow
        if (showSuggestions) {
          if (selectedSuggestionIndex > 0) {
            this.setState({ selectedSuggestionIndex: selectedSuggestionIndex - 1 })
          } else {
            this.setState({ showSuggestions: false })
          }
          handledKey = true
        }
        break
      case 40: // down arrow
        if (showSuggestions) {
          if (selectedSuggestionIndex < suggestions.length - 1) {
            this.setState({ selectedSuggestionIndex: selectedSuggestionIndex + 1 })
            handledKey = true
          }
        } else {
          this.setState({ showSuggestions: true })
          handledKey = true
        }
        break
    }

    if (handledKey) {
      e.preventDefault()
      e.stopPropagation()
    }
  }

  renderSuggestions () {
    const { suggestions, selectedSuggestionIndex, showSuggestions } = this.state

    if (!showSuggestions || (suggestions.length === 0)) {
      return undefined
    }

    const items = suggestions.map((suggestion, index) => {
      const selected = index === selectedSuggestionIndex
      return <Suggestion key={suggestion} suggestion={suggestion} selected={selected} onClick={this.handleSuggestionClick} />
    })

    let style = {}
    if (this.inputRef.current) {
      const width = this.inputRef.current.getBoundingClientRect().width
      style = { width }
    }

    return (
      <div id='suggestions' className={css.suggestions} style={style}>
        { items }
      </div>
    )
  }

  render () {
    const { name, placeholder, id } = this.props

    return (
      <div className={css.autoSuggest} ref={this.containerRef}>
        <input
          id={id || undefined}
          ref={this.inputRef}
          name={name || undefined}
          placeholder={placeholder}
          type='text'
          autoComplete='off'
          value={this.state.query}
          onChange={this.handleInputChange}
          onKeyDown={this.handleKeyDown}
        />
        {this.renderSuggestions()}
      </div>
    )
  }
}
