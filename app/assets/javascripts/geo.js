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

$(document).ready(function () {
  if ( document.getElementById( 'member_order_buttons' )) { //check for elem unique to this view

    navigator.geolocation.getCurrentPosition(success, error, options); // HTML5 Geolocation

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
