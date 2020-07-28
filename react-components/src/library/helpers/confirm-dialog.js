import React, { useState } from 'react'
import Button from '@material-ui/core/Button'
import Dialog from '@material-ui/core/Dialog'
import DialogActions from '@material-ui/core/DialogActions'
import DialogContent from '@material-ui/core/DialogContent'
import DialogTitle from '@material-ui/core/DialogTitle'
import { makeStyles } from '@material-ui/core/styles'

const dialogStyles = makeStyles({
  paper: {
    borderRadius: '0',
    padding: '20px'
  }
})
const dialogTitleStyles = makeStyles({
  root: {
    color: '#ea6d2f',
    padding: '20px'
  }
})
const dialogContentStyles = makeStyles({
  root: { padding: '0 20px' }
})
const dialogActionsStyles = makeStyles({
  root: {
    padding: '0 20px 20px 20px'
  }
})
const buttonStyles = makeStyles({
  root: {
    backgroundColor: '#ea6d2f',
    borderRadius: 0,
    color: '#ffffff',
    margin: '0 auto',
    padding: '15px 20px',
    '&:hover': {
      backgroundColor: '#ea6d2f',
      borderRadius: 0,
      color: '#ffffff',
      margin: '0 auto',
      padding: '15px 20px'
    }
  },
  contained: {
    boxShadow: 'none',
    transition: '.2s',
    '&:hover': {
      background: '#ffc320',
      boxShadow: 'none',
      transition: '.2s'
    }
  }
})

const ConfirmDialog = (props) => {
  const [open, setOpen] = useState(true)
  const { title, children, onConfirm } = props

  const handleClose = () => {
    setOpen(false)
    onConfirm()
  }

  const dialogClasses = dialogStyles()
  const dialogTitleClasses = dialogTitleStyles()
  const dialogContentClasses = dialogContentStyles()
  const dialogActionsClasses = dialogActionsStyles()
  const buttonClasses = buttonStyles()

  const dialogTitle = title ? <DialogTitle id='confirm-dialog' classes={{ root: dialogTitleClasses.root }}>{title}</DialogTitle> : null

  return (
    <Dialog classes={{ paper: dialogClasses.paper }} open={open} onClose={() => setOpen(false)}>
      {dialogTitle}
      <DialogContent classes={{ root: dialogContentClasses.root }}>{children}</DialogContent>
      <DialogActions classes={{ root: dialogActionsClasses.root }}>
        <Button classes={{ root: buttonClasses.root, contained: buttonClasses.contained }} variant='contained' onClick={() => handleClose()}>
          OK
        </Button>
      </DialogActions>
    </Dialog>
  )
}
export default ConfirmDialog
