import React from 'react'

import css from './style.scss'

export default class CopyDialog extends React.Component<any, any> {
  constructor (props: any) {
    super(props)
    const { name, classWord, description } = props.clazz
    this.state = {
      name: `Copy of ${name}`,
      classWord: `Copy of ${classWord}`,
      description
    }
    this.handleUpdateName = this.handleUpdateName.bind(this)
    this.handleUpdateClassWord = this.handleUpdateClassWord.bind(this)
    this.handleUpdateDescription = this.handleUpdateDescription.bind(this)
    this.handleSave = this.handleSave.bind(this)
  }

  handleUpdateName (e: any) {
    this.setState({ name: e.target.value })
  }

  handleUpdateClassWord (e: any) {
    this.setState({ classWord: e.target.value })
  }

  handleUpdateDescription (e: any) {
    this.setState({ description: e.target.value })
  }

  handleSave () {
    const { name, classWord, description } = this.state
    this.props.handleSave({ name, classWord, description })
  }

  render () {
    const { handleCancel, saving } = this.props
    const { name, classWord, description } = this.state

    const cancelSubmit = (e: any) => {
      e.preventDefault()
      e.stopPropagation()
    }
    const saveDisabled = saving || name.trim().length === 0 || classWord.trim().length === 0

    return (
      <div className={css.copyDialogLightbox}>
        <div className={css.copyDialogBackground} />
        <div className={css.copyDialog}>
          <div className={css.copyTitle}>Copy Class</div>
          <form onSubmit={cancelSubmit}>
            <table>
              <tbody>
                <tr>
                  <td><label htmlFor='name'>Name</label></td>
                  <td><input name='name' value={name} onChange={this.handleUpdateName} /></td>
                </tr>
                <tr>
                  <td><label htmlFor='class_word'>Class Word</label></td>
                  <td><input name='class_word' value={classWord} onChange={this.handleUpdateClassWord} /></td>
                </tr>
                <tr>
                  <td className={css.description}><label htmlFor='description'>Description</label></td>
                  <td><textarea name='description' value={description} onChange={this.handleUpdateDescription} /></td>
                </tr>
                <tr>
                  // @ts-expect-error TS(2322): Type 'string' is not assignable to type 'number'.
                  <td colSpan={2} className={css.buttons}>
                    <button disabled={saveDisabled} onClick={this.handleSave}>{saving ? 'Saving ...' : 'Save'}</button>
                    <button onClick={handleCancel}>Cancel</button>
                  </td>
                </tr>
              </tbody>
            </table>
          </form>
        </div>
      </div>
    )
  }
}
