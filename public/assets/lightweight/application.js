$(document).ready(function() {
	// prepare for scrolling model
	calculateDimensions();
	$(document).bind('scroll', $scroll_handler);
	
	// add event listeners
	$('input[type=radio]').click(function(){
		$('#check').removeClass('disabled');
	});
	
	$('#header').click(function(){
		maxHeader();
	});
	$('#overlay').click(function(){
		exitFullScreen();
	});
	$('.full-screen-toggle').click(function(){
		fullScreen();
		return false;
	});
});


var $content_height;
var $content_offset;
var $content_top;
var $content_bottom;
var $last_scroll_pos = $(document).scrollTop();
var $stop_scrolltop;
var $model_width;

function calculateDimensions(){
  $content_height = $('.content').height();
  $content_offset = $('.content').offset();
  $content_top = $content_offset.top;
  $content_bottom = $(document).height() - ($content_top + $content_height);
  $model_height = $('.model').height();
  $model_width = $('.model').css('width');
}

$(window).resize(function(){
	calculateDimensions();
});

function checkAnswer() {
	// check for valid answer
	if (!$('input:radio[name=q1]:checked').val()) {
		alert('Please select an answer before checking.');
	} else {
		if ($('input:radio[name=q1]:checked').val() == 50) {
			alert('Correct!');
			$('#next').removeClass('disabled');
		} else {
			alert('That answer is incorrect.');
			$('#next').addClass('disabled');
		}
	}
}

function maxHeader() {
	$('#header').unbind('click').click(function(){
		minHeader();	
	}).animate({'height': '130px'}, 300, function(){
		$('#header nav').fadeIn();	
	});
	$('#header h1').animate({'height': '78px', 'width': '372px'}, 300);
	$('#header p').animate({'height': '56px', 'margin-top': '15px', 'width': '182px'}, 300);
}

function minHeader() {
	$('#header nav').fadeOut();
	$('#header h1').animate({'height': '50px', 'width': '238px'}, 300);
	$('#header p').animate({'height': '40px', 'margin-top': '10px', 'width': '130px'}, 300);
	$('#header').click(function(){
		maxHeader();	
	}).animate({'height': '60px'}, 300);
}

function fullScreen() {
	$(document).unbind('scroll');
	$('#overlay').fadeIn('fast');
	$('.model').fadeOut('fast');
	
	$('.full-screen-toggle').attr('onclick', '').click(function(){
		exitFullScreen();
		return false;
	});
	$('.full-screen-toggle').html('Exit Full Screen');
	$('.model').css({'height': '90%', 'left': '5%', 'margin': '0', 'position': 'fixed', 'top': '5%', 'width': '90%', 'z-index': '100'});
	$('.model iframe').css({'height': '100%', 'width': '100%'});
	$('.model').fadeIn('fast');
}

function showTutorial() {
	$('#overlay').fadeIn('fast');
	$('#tutorial').fadeIn('fast');
}

function exitFullScreen() {
	if (!($('body').hasClass('full'))) {
		$(document).bind('scroll', $scroll_handler);
	}
	$('#tutorial').fadeOut('fast');
	$('.model').fadeOut('fast');
	$('.full-screen-toggle').unbind('click').click(function(){
		fullScreen();
		return false;
	});
	$('.full-screen-toggle').html('Full Screen');
	$('.model').css({'height': '510px', 'left': 'auto', 'margin': '13px 0 20px', 'position': 'relative', 'top': 'auto', 'width': '100%', 'z-index': '1'});
	$('#overlay').fadeOut('slow');
	$('.model').fadeIn('fast');
}

var $scroll_handler = function() {
	if ($(document).scrollTop() > 60 && $(document).scrollTop() < 821) {
    $('.model').css({'position': 'absolute', 'top': $(document).scrollTop() + 'px', 'width': $model_width});
		$value = $content_top + $content_height;
	} else if ($(document).scrollTop() >= 821) {
    $(',model').css({'position': 'absolute', 'top': '821px', 'width': $model_width});
	} else {
    $(',model').css({'position': 'absolute', 'top': '64px', 'width': $model_width});
	}
};

function nextQuestion(num) {
	var curr_q = '.q' + (num - 1);
	var next_q = '.q' + num;
	$(curr_q).fadeOut('fast', function(){$(next_q).fadeIn();});
}

function prevQuestion(num) {
	var curr_q = '.q' + (num + 1);
	var next_q = '.q' + num;
	$(curr_q).fadeOut('fast', function(){$(next_q).fadeIn();});
}

function adjustWidth() {
	var model_width;
	var width;
	if ($('.content').css('width') == '960px') {
		model_width = '60%';
		width = '95%';
	} else {
		model_width = '576px';
		width = '960px';		
	}
	
	$('#header div').css('width', width);
	$('.content').css('width', width);
	$('.model').css('width', model_width);
	$('#footer div').css('width', width);
}
;
// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.
;
// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// the compiled file.
//
// WARNING: THE FIRST BLANK LINE MARKS THE END OF WHAT'S TO BE PROCESSED, ANY BLANK LINE SHOULD
// GO AFTER THE REQUIRES BELOW.
//



;
