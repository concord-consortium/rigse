// Some helpers for toggling checkboxes in the learner and offering reports.
// requires prototype
/*globals $$ */

function set(parentId, selected) {
  $$(parentId + ' input.filter_checkbox').each(function(box){ box.checked = selected; } );
  return false;
}

function selectAll(parentId) {
  return set(parentId, true);
}

function selectNone(parentId) {
  return set(parentId, false);
}