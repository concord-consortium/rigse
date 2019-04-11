function confirmUserDelete(formID, username) {
  var promptResponse = prompt('Are you sure you want to delete user ' + username + '? This cannot be undone! Enter DELETE if you are sure.');
  if (promptResponse === 'DELETE') {
    document.getElementById(formID).submit();
  } else {
    alert('User NOT deleted.');
  }
}
