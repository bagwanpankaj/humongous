$(document).ready(function(){
  $('.database_list tr').click( function( e ){
    var data_source = $( e.target ).attr( "data-source" );
    $( this ).siblings().removeClass('active');
    $( this ).addClass( 'active' );
    app.ax({
      url: data_source,
      type: 'GET',
      success: function( data ){
        if( data && data.header ) app.helpers.header( data.header, false );
        app.storage.remove("collection");
        app.storage.set("database", $(e.target).text());
        $( app.html.collection.create( data.collections ) ).appendTo( '.collections_list' );
        app.helpers.yielder( app.html.stats, data.stats );
      }
    })
  } );
  $( '.query_link' ).live( 'click', function( e ){
    var db = app.storage.get("database"), coll = app.storage.get("collection")
    if(db && !coll){
      alert("Please choose a collection first.")
      return false;
    }
    app.helpers.yielder( app.html.query_browser, {} );
    e.preventDefault();
  } );
  $( '.yielder form' ).live( 'submit', function( e ){
    var db = app.storage.get("database"), coll = app.storage.get("collection")
    if(db && !coll){
      alert("Please choose a collection first.")
      return false;
    }
    e.preventDefault();
    app.ax({
      url: '/database/'+ db +'/collection/' + coll + '/page/' + 1,
      data: $(this).serialize(),
      success: function( data ){
        app.storage.set("result_set", data );
        $( app.html.build_results.create( data ) ).appendTo( '.query_result' );
      }
    })
  } )
});
app.helpers.yielder = function( cb_function, arguments ){
  $( cb_function.create( arguments ) ).appendTo( '.yielder' );
};
app.helpers.header = function( new_header, query ){
  query = query || false
  $( '.header' ).text( new_header );
  if(query){
    $( '.query_link' ).html( '<a href="#", class="btn primary">Query</a>' );
  }else{
    $( '.query_link' ).html( '' );
  }
};
app.html.collection = {
  selector: '.collections_list',
  clear: function(){
    $( this._el() ).children().remove();
  },
  create: function( collections ){
    this.clear();
    var self = this;
    var db = app.storage.get("database");
    var get_children = function( collections ){
      var res = []
      $.each( collections, function( _, v ){
        res.push({ tag: "TR", onClick: self._collection_handler, children: [
          { tag: "TD", "data-source": '/database/' + db + '/collection/' + v, text: v }
        ] });
      } );
      return res;
    }
    return(
        { tag: "TABLE", children: [
          { tag: "TBODY", children: get_children( collections ) }
        ] }
      )
  },
  _collection_handler: function( e ){
    var data_source = $( e.target ).attr( "data-source" );
    $( this ).siblings().removeClass('active');
    $( this ).addClass( 'active' );
    app.ax({
      url: data_source,
      type: 'GET',
      success: function( data ){
        if( data && data.header ) app.helpers.header( data.header, true );
        app.storage.set("collection", $(e.target).text());
        app.helpers.yielder( app.html.stats, data.stats );
      }
    })
  },
  _el: function(){
    return $(this.selector);
  }
}
app.html.stats = {
  selector: '.yielder',
  clear: function(){
    $( this._el() ).children().remove();
  },
  create: function( stats_json ){
    this.clear();
    return(
      { tag: "TABLE", cls: 'zebra-striped', children: 
        [
          { tag: "TBODY", children: this._build_children( stats_json ) }
        ]
      }
    )
  },
  _build_children: function( stats_json ){
    var chidren = [];
    for( key in stats_json ){
      chidren.push(
        { tag: "TR", children: [
          { tag: "TH", text: key },
          { tag: "TD", text: this._format_object( stats_json[key] ) }
        ] }
      )
    };
    return chidren;
  },
  _el: function(){
    return $(this.selector);
  },
  _format_object: function( value ){
    if( app.isObject( value ) ){
      return JSON.stringify( value );
    }else{
      return value.toString();
    }
  }
}