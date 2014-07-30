// Just add element with 'wait-message' class to your page and then call
// startWaiting(<some message>) and stopWaiting when long action is complete.

// Preload wait image so user doesn't have to wait for it.
new Image().src = "/assets/wait16.gif";

function startWaiting(message) {
	var div = jQuery('<div>').appendTo('.wait-message');
	jQuery('<img alt="waiting" src="/assets/wait16.gif" class="wait-image">').appendTo(div);
	jQuery('<span class="wait-text">').text(message).appendTo(div);
}

function stopWaiting() {
	jQuery('.wait-message').empty();
}
