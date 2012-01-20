app.storage = {
	local: window.localStorage, // storage to be used
	set: function( key, value ){
		this.local.setItem( key, JSON.stringify( value ) );
		$( document ).trigger( 'storage', ['set', key, value] );
	},
	get: function( key ){
		return JSON.parse( this.local.getItem( key ) );
	},
	key: function( index ){
		return this.local.key( index );
	},
	remove: function( key ){
		this.local.removeItem( key );
		$( document ).trigger( 'storage', ['remove', key] );
	},
	clear: function(){
		return this.local.clear();
		$( document ).trigger( 'storage', ['clear'] );
	},
	keys: function(){
		var res = [];
		for( var i = 0; i < this.local.length; i++ ){
			res.push( this.local.key( i ) );
		};
		return res;
	}
};