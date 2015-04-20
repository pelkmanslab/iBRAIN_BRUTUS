function highlightRows() {
	checkUrl();
	checkIfPageIsStillFresh();
}

function highlightRows_DEFUNCT() {
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
	checkUrl();
}

function checkUrl() {
	urlquery=location.href.split("?");
	if (urlquery[1]) {
		urlterms=urlquery[1].split(",");
		var link = document.getElementById('showAdvancedColumns');
		if (urlterms) {
			for (var i=0; i<urlterms.length; i++) {
				if (urlterms[i].split("#")) {
					strTemp = urlterms[i].split("#");
					urlterms[i] = strTemp[0];
				}
				if ((urlterms[i].substring(0,1) == 'A') && (link.innerHTML == '&gt;&gt;')) {	
					showAdvancedColumns();
				} else if (!isNaN(urlterms[i])) {
					if (document.getElementById(urlterms[i])) {
							//changeiFrameUrl(document.getElementById(urlterms[i]).href);
							window.frames['projectFrame'].location = document.getElementById(urlterms[i]).href;
					}
				}
			}
		}
	}
}

function checkIfPageIsStillFresh() {
	var reportField = document.getElementById('reportStalePage');
	var headerTD = document.getElementById('HeaderTD');
	var headerTR = document.getElementById('HeaderTR');
	var reportStalePage2 = document.getElementById('reportStalePage2');

	varCurrentDate = new Date();
	varPageDate = Date.parse(reportField.innerHTML)

	//alert(reportField.innerHTML)
	//alert(varPageDate)
	//alert(varCurrentDate)
	//alert((varCurrentDate - varPageDate))

	// if page date is older than 1 hour, set website to offline style
	if ((varCurrentDate - varPageDate) > (1000*60*60)) {
	if (reportStalePage2) {
		reportStalePage2.className = 'reportStalePage2Online';
	}
	if (reportField) {
	reportField.innerHTML = '('+Math.round((varCurrentDate - varPageDate)/(1000*60*60))+' hours ago)';
	reportField.style.display = 'inline';
	reportField.style.color = '#880000';
	}
	if (headerTD) {
		headerTD.className = 'headerOffline';
	}
	if (headerTR) {
		headerTR.className = 'headerTrOffline';
	}
	}
}


function showAdvancedColumns() {
	var link = document.getElementById('showAdvancedColumns');
	//alert(link.innerHTML)
	if ((link.innerHTML == '&gt;&gt;') || (link.innerHTML == '>>')) {
		//settings to display all advanced fields
		var strDisplaySetting = 'table-cell';
		var strLink = '&lt;&lt;'
		var intColspan = '9';
	} else {
		//settings to hide all advanced fields
		var strDisplaySetting = 'none';
		var strLink = '&gt;&gt;';
		var intColspan = '6';
	}

	link.innerHTML = strLink;
	document.getElementById('columnTitleCell').colSpan=intColspan;
	
	//alert(document.getElementById('navTable'))	
	
	var tds = document.getElementById('navTable').getElementsByTagName('td');

	//alert(tds.length)	
	
	for (var i=0; i<tds.length; i++) {
		if (tds[i].getAttribute('id')) {
			if (tds[i].getAttribute('id').substring(0,9) == '_advanced') {
				tds[i].style.display = strDisplaySetting;
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

function changeiFrameUrl(strUrl,strProjId) {
	// window.frames['projectFrame'].location = strUrl;

	var link = document.getElementById('showAdvancedColumns');
	urlquery=location.href.split("?");
	newurl=urlquery[0];
	newurl+='?';
	if (link.innerHTML == '&lt;&lt;') {	
		newurl+='A,';
	}
	newurl+=strProjId;		
	// location.href="#top";
	location.href=newurl;
	scroll(0,0)
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