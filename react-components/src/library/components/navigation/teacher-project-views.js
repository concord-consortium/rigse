import React from 'react'
import css from './style.scss'

export default class TeacherProjectViews extends React.Component {
  constructor (props) {
    super(props)
    this.state = {
      loaded: false,
      showLoadingMessage: false,
      teacherProjectViews: null
    }
    this.getTeacherProjectViews = this.getTeacherProjectViews.bind(this)
  }

  componentDidMount () {
    this.timerHandler = setTimeout(() => {
      this.setState({ showLoadingMessage: true })
      this.timerHandler = 0
    }, 500)
    this.getTeacherProjectViews()
  }

  componentWillUnmount () {
    if (this.timerHandle) {
      clearTimeout(this.timerHandle)
      this.timerHandle = 0
    }
  }

  getTeacherProjectViews () {
    if (!Portal.API_V1.GET_TEACHER_PROJECT_VIEWS) {
      // This can happen if this component is rendered by someone other than a teacher
      return
    }
    jQuery.ajax({
      url: Portal.API_V1.GET_TEACHER_PROJECT_VIEWS,
      dataType: 'json',
      success: function (data) {
        this.setState({
          teacherProjectViews: data,
          loaded: true
        })
      }.bind(this)
    })
  }

  teacherProjectViewsList () {
    const { showLoadingMessage, teacherProjectViews, loaded } = this.state
    if (!loaded) {
      if (showLoadingMessage === false) {
        return null
      }
      return (
        <div className={css.loading}>
          Loading...
        </div>
      )
    // below is for when list data is loaded
    } else {
      if (teacherProjectViews.length === 0) {
        return null
      }
      return (
        <ul className={css.teacherProjectViews__list}>
          {
            Object.keys(teacherProjectViews).map(key => {
              let imgStyle = {
                backgroundImage: 'url(' + teacherProjectViews[key].project_card_image_url + ')'
              }
              return (
                <li className={css.teacherProjectViews__list_item} key={teacherProjectViews[key].id}>
                  <a href={'/' + teacherProjectViews[key].landing_page_slug}>
                    <span className={css.teacherProjectViews__list_item_img} style={imgStyle} />
                    <span className={css.teacherProjectViews__list_item_name}>
                      {teacherProjectViews[key].name}
                    </span>
                  </a>
                </li>
              )
            })
          }
        </ul>
      )
    }
  }

  render () {
    let teacherProjectViewsList = this.teacherProjectViewsList()
    if (!teacherProjectViewsList) {
      return null
    }

    return (
      <div className={css.teacherProjectViews}>
        <h2>Recently Visited Collections</h2>
        {teacherProjectViewsList}
      </div>
    )
  }
}
