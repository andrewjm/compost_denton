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

window.onload = function() {

  // *** This bit needs to be loaded only on the correct page,
  //     else it will throw an err on every other page.
  //     http://stackoverflow.com/questions/18724247/rails-and-page-specific-javascript

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
    navigator.geolocation.getCurrentPosition(success, error, options); // HTML5 Geolocation
    url = location.href.split(/[?#]/)[0];
    location.href = url + "?order=locale";
  };
}
