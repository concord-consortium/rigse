import React from 'react'
import { throttle, debounce } from 'throttle-debounce'

import css from './auto-suggest.scss'

class Suggestion extends React.Component {
  render () {
    const { suggestion } = this.props
    const onClick = () => this.props.onClick(suggestion)
    return <div className={css.suggestion} onClick={onClick}>{suggestion}</div>
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
    const { query } = this.state
    if (query.length > 0) {
      this.search(query)
    }
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
    const { query, skipAutoSearch } = nextProps
    if (query !== undefined) {
      // reset and hide the suggestions when the query is changed
      this.setState({ query, suggestions: [], selectedSuggestionIndex: -1, showSuggestions: false }, () => {
        if (!skipAutoSearch && (query.length > 0)) {
          this.search(query)
        }
      })
    }
  }

  search (query) {
    const setSuggestions = (suggestions, callback) => {
      const showSuggestions = suggestions.length > 0
      this.setState({ suggestions, selectedSuggestionIndex: -1, showSuggestions }, callback)
    }
    const trimmedQuery = query.trim()
    this.currentQuery = trimmedQuery
    if (trimmedQuery.length === 0) {
      setSuggestions([])
    } else {
      const { getQueryParams } = this.props
      const queryParams = getQueryParams ? (getQueryParams() || '').replace(/search_term=([^&]*&?)/, '') : ''
      const data = `search_term=${encodeURIComponent(trimmedQuery)}${queryParams.length > 0 ? `&${queryParams}` : ''}`

      if (this.queryCache[data]) {
        setSuggestions(this.queryCache[data])
      } else {
        setSuggestions([], () => {
          jQuery.ajax({
            url: '/api/v1/search/search_suggestions',
            data,
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
        })
      }
    }
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
    const { query, suggestions, selectedSuggestionIndex, showSuggestions } = this.state

    switch (e.keyCode) {
      case 13: // enter
        const { onChange, onSubmit } = this.props
        const suggestion = suggestions[selectedSuggestionIndex]
        const hasSuggestionSelected = suggestion !== undefined
        if (showSuggestions && hasSuggestionSelected) {
          this.setState({ query: suggestion, showSuggestions: false, selectedSuggestionIndex: -1 }, () => {
            if (onChange) {
              onChange(suggestion)
            }
            if (onSubmit) {
              onSubmit(suggestion)
            }
          })
          handledKey = true
        } else if (onSubmit) {
          onSubmit(query)
          handledKey = true
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
            const index = selectedSuggestionIndex - 1
            const query = suggestions[index]
            this.setState({ selectedSuggestionIndex: index, query })
          } else {
            this.setState({ selectedSuggestionIndex: -1, showSuggestions: false })
          }
          handledKey = true
        }
        break
      case 40: // down arrow
        if (showSuggestions) {
          if (selectedSuggestionIndex < suggestions.length - 1) {
            const index = selectedSuggestionIndex + 1
            const query = suggestions[index]
            this.setState({ selectedSuggestionIndex: index, query })
            handledKey = true
          }
        } else if (suggestions.length > 0) {
          this.setState({ selectedSuggestionIndex: 0, showSuggestions: true })
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
    const { suggestions, showSuggestions } = this.state

    if (!showSuggestions || (suggestions.length === 0)) {
      return undefined
    }

    const items = suggestions.map((suggestion, index) => {
      return <Suggestion key={suggestion} suggestion={suggestion} onClick={this.handleSuggestionClick} />
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
        <input
          id={css.keywordSubmit}
          type='submit'
          name='keywordSubmit'
          value='Go'
          onKeyDown={this.handleKeyDown}
          onClick={this.handleKeyDown}
        />
        {this.renderSuggestions()}
      </div>
    )
  }
}
