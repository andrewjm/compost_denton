// HTML5 Geolocation
var options = {
  enableHighAccuracy: true,
  timeout: 5000,
  maximumAge: 0
};

function success(pos) {
  var crd = pos.coords;

  console.log('Your current position is:');
  console.log('Latitude : ' + crd.latitude);
  console.log('Longitude: ' + crd.longitude);
  console.log('More or less ' + crd.accuracy + ' meters.');

  document.cookie = "latitudine="+crd.latitude;
  document.cookie = "longitudine="+crd.longitude;

  console.log('Cookie:');
  console.log(document.cookie);
};

function error(err) {
  console.warn('ERROR(' + err.code + '): ' + err.message);
};

function getParameterByName(name) {
  name = name.replace(/[\[]/, "\\[").replace(/[\]]/, "\\]");
  var regex = new RegExp("[\\?&]" + name + "=([^&#]*)"),
      results = regex.exec(location.search);
  return results === null ? "" : decodeURIComponent(results[1].replace(/\+/g, " "));
};

function setBtnColor(name) {
 switch(getParameterByName(name)) {
    case 'first':
	// Set btn-first to primary color
	document.getElementById( "btn-first" ).className  += " btn-primary";
	document.getElementById( "btn-last" ).className   += " btn-default";
	document.getElementById( "btn-locale" ).className += " btn-default";
        break;
    case 'last':
	// Set btn-last to primary color
        document.getElementById( "btn-first" ).className  += " btn-default";
        document.getElementById( "btn-last" ).className   += " btn-primary";
        document.getElementById( "btn-locale" ).className += " btn-default";
        break;
    case 'locale' :
	// Set btn-locale to primary color
        document.getElementById( "btn-first" ).className  += " btn-default";
        document.getElementById( "btn-last" ).className   += " btn-default";
        document.getElementById( "btn-locale" ).className += " btn-primary";
        break;
    default:
	// Set btn-locale to primary color
        document.getElementById( "btn-first" ).className  += " btn-default";
        document.getElementById( "btn-last" ).className   += " btn-default";
        document.getElementById( "btn-locale" ).className += " btn-primary";
  } 
};

$(document).ready(function () {
  if ( document.getElementById( 'profile_stats'  )) { // check for elem unique to profile view
    navigator.geolocation.getCurrentPosition(success, error, options); // HTML5 Geolocation
  };

  if ( document.getElementById( 'member_order_buttons' )) { //check for elem unique to member-sort view

    navigator.geolocation.getCurrentPosition(success, error, options); // HTML5 Geolocation

    setBtnColor('order');

    // Button Logic
    var url = "";
    document.getElementById("btn-first").onclick = function () {
      url = location.href.split(/[?#]/)[0];
      location.href = url + "?order=first";
    };
    document.getElementById("btn-last").onclick = function () {
      url = location.href.split(/[?#]/)[0];
      location.href = url + "?order=last";
    };
    document.getElementById("btn-locale").onclick = function () {
      url = location.href.split(/[?#]/)[0];
      location.href = url + "?order=locale";
    };
  };
});
