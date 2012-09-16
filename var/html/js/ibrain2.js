function highlightRows() {
	var trs = document.getElementsByTagName('tr');
	for (var i=0; i<trs.length; i++) {
		if (!(trs[i].className == 'noRow') && !(trs[i].className == 'statusInfo')) {
			if ( trs[i].className=='oddRow' ) { 
				trs[i].onmouseover = function() { this.className = 'oddRow_over'; }
				trs[i].onmouseout = function() { this.className = 'oddRow'; }
			} else if ( trs[i].className=='evenRow' ) {
				trs[i].onmouseover = function() { this.className = 'evenRow_over'; }
				trs[i].onmouseout = function() { this.className = 'evenRow'; }			
			} else if ( trs[i].className=='statusItem' ) {
				trs[i].onmouseover = function() { this.className = 'statusItem_over'; }
				trs[i].onmouseout = function() { this.className = 'statusItem'; }			
 			} else if ( trs[i].className=='errorRow' ) {
				trs[i].onmouseover = function() { this.className = 'errorRow_over'; }
				trs[i].onmouseout = function() { this.className = 'errorRow'; }			
			}
		}
	}
}

function formHandler(form){
	if (form.selectedIndex > 0) {
		window.open(form.options[form.selectedIndex].value);
	};
	//var URL = document.form.site.options[document.form.site.selectedIndex].value;
	//window.location.href = URL;
	//window.open(URL);
}

function switchDisplay(elementId, tagName) {
	var trs = document.getElementsByTagName(tagName);
	for (var i=0; i<trs.length; i++) {
		if (trs[i].getAttribute('id') == elementId) {
			changeDisplayStyle(trs[i]);
		}
	}
}

function changeDisplayStyle(element) {
	if (element && element.style) {
		if (!(element.style.display == 'none')) {
			element.style.display = 'none';
		} else {
			element.style.display = 'table-row';
		}
	}
}

function changeiFrameUrl(strUrl) {
	window.frames['projectFrame'].location = strUrl;
}

function collapseAllPlates() {
	var trs = document.getElementsByTagName('tr');
	for (var i=0; i<trs.length; i++) {
		if (trs[i].getAttribute('id')) {
			if (trs[i].getAttribute('id').substring(0,6) == 'plate_') {
				trs[i].style.display = 'none';				
			}
		}
	}
}

function expandAllPlates() {
	var trs = document.getElementsByTagName('tr');
	for (var i=0; i<trs.length; i++) {
		if (trs[i].getAttribute('id')) {
			if (trs[i].getAttribute('id').substring(0,6) == 'plate_') {
				trs[i].style.display = 'table-row';
			}
		}
	}
}


// function onloadiFrame() {
// 	document.getElementById('main').innerHTML = window.frames['projectFrame'].document.getElementById('container').innerHTML;
// 	// add highlightRows to add the onmouseover onmouseout stylechanges to the new table rows
// 	highlightRows();
// }