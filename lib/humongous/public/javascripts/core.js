app = {};
app.html = {};
app.html.template = {};
app.storage = {};
app.helpers = {};

app.isObject = function (value) {
	return Object.prototype.toString.call(value) == "[object Object]";
};
//adding storage event
$( document ).bind( 'storage', function( e, action, on, values ){
	console.log(arguments);
	$( '.expression_selector' ).trigger( e.type, [ action, on, values ] );
} );

app.remove = function( array, elem ){
	for( var i = 0; i < elem.length; i++ ){
		while( ( match = array.indexOf( elem[i] ) ) > -1 ){
			array.splice(match, 1);
		}
	}
	return array;
};
app.capitalize = function( string ){
	return string.replace(/^\w/, function($0) { return $0.toUpperCase(); })
};
app.compact = function( array ){
	var ret = [];
	for( var i = 0; i < array.length; i++ ){
		if( !!array[i] )
			ret.push( array[i] )
	}
	return ret;
};
app.contains = function( array, element ){
	if( array.indexOf( element ) > -1 ) return true;
	return false;
};
app.keys = function( obj ){
	var ret = [];
	for( var key in obj ){
		ret.push( key );
	}
	return ret;
};
app.merge = function( base, obj ){
    var res = {};
    for( var attrname in base ) { res[attrname] = base[attrname]; }
    for( var attrname in obj ) { res[attrname] = obj[attrname]; }
    return res;
};
app.ajax = app.ax = function( options ){
	var defaults = {
		type: 'POST',
		dataType: 'JSON',
	};
	options = $.extend( defaults, options );
	console.log("making request with " + JSON.stringify( options, null, '\t' )  );
	$.ajax( options );
};