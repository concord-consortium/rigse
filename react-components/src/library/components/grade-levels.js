import Component from '../helpers/component'
import filters from '../helpers/filters'

const GradeLevels = Component({

  render: function () {
    var resource = this.props.resource
    var levels = filters.gradeFilters.reduce(function (levelAcc, gradeFilter) {
      var matching = gradeFilter.grades.reduce(function (matchingAcc, grade) {
        if (resource.grade_levels && resource.grade_levels.indexOf(grade) !== -1) {
          matchingAcc.push(grade)
        }
        return matchingAcc
      }, [])
      if (matching.length > 0) {
        levelAcc.push(gradeFilter.label)
      }
      return levelAcc
    }, [])

    if (levels.length === 0) {
      return null
    }

    return (
      <div className={this.props.className || 'portal-pages-finder-result-grade-levels'}>
        {levels.map((level, index) => {
          if (level === 'Higher Education') {
            level = 'Higher Ed'
          }
          return <div key={index} className='portal-pages-finder-result-grade-level'>{level}</div>
        })}
      </div>
    )
  }
})

export default GradeLevels
