// ENSURE MINIMUM VALUE OF ZERO
function weight_floor( elem ) {
  if ( elem.value < 0 ) {
    elem.value = parseInt( 0, 10 );
  }
}

// ADD VALUE TO INPUT
function weight_add( val, elem ) {
  var tmp = parseInt( elem.value, 10 );
  tmp += parseInt( val, 10 );
  elem.value = tmp;
}

// SUBTRACT VALUE FROM INPUT
function weight_subtract( val, elem ) {
  var tmp = parseInt( elem.value, 10 );
  tmp -= parseInt( val, 10 );
  elem.value = tmp;
  weight_floor( elem );
}

$(document).ready(function () {
  if ( document.getElementById( 'weight_buttons' ) ) { //check for elem unique to this view

    var input   = document.getElementById( 'weight_log_input' );
    input.value = parseInt( 0, 10 ); //ensure value is an int & set to zero

    // ADDITION BUTTONS
    document.getElementById( '+50' ).onclick = function() { weight_add( 50, input ); }
    document.getElementById( '+10' ).onclick = function() { weight_add( 10, input ); }
    document.getElementById( '+5' ).onclick  = function() { weight_add( 5,  input ); } 
    document.getElementById( '+1' ).onclick  = function() { weight_add( 1,  input ); }

    // SUBTRACTION BUTTONS
    document.getElementById( '-50' ).onclick = function() { weight_subtract( 50, input ); }
    document.getElementById( '-10' ).onclick = function() { weight_subtract( 10, input ); }
    document.getElementById( '-5' ).onclick  = function() { weight_subtract( 5,  input ); }
    document.getElementById( '-1' ).onclick  = function() { weight_subtract( 1,  input ); }
  };
});
