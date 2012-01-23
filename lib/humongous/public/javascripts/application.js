$(document).ready(function(){
  $('#loader').modal({
    keyboard: true,
    backdrop: "static"
  });
  $("#loader").bind("ajaxSend", function(){
    $( this ).modal('show');
  }).bind("ajaxComplete", function(){
    $( this ).modal('hide');
  });
  $('.database_list tr').live('click', function( e ){
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
  } );
  $(".databases .delete").bind( 'click', function(e){
    var elem = $(".database_list").find(".active");
    if(!!elem){
      alert("Please choose a database to delete.");
      return false;
    }
    var data_source = elem.children().attr("data-source");
    app.ax({
      url: data_source,
      type: "DELETE",
      success: function(data){
        console.log("DELETED: " + JSON.stringify(data));
        $(elem).remove();
      }
    });
  } );
  $(".databases .add").bind( 'click', function(e){
    $("#modal_skeleton.modal").remove();
    var modal_skeleton = app.html.modal_skeleton.create( "modal_skeleton" );
    var input_field = app.html.template.input_field
    modal_skeleton.children[0].children = [
      { tag: "H3", text: "Add Database" }
    ];
    modal_skeleton.children[1].children = [
      input_field.container({
        id: "database_name",
        name: "database_name",
        text: "Name",
        placeholder: "Database Name",
        size: "30"
      })
    ];
    modal_skeleton.children[2].children = [
      { tag: "A", cls: "btn primary", text: "Add" }
    ]
    $( "#modal_skeleton a" ).live("click", function(e){
      $( "#modal_skeleton" ).modal('hide');
      app.ax({
        url: "/database",
        data: { database_name: $("#database_name").val() },
        success: function(data){
          if(data["created"]){
            $(".database_list table tbody").append("<tr><td data-source='/database/"+data["name"]+"'>"+data["name"]+"</td></tr>")
          }
        }
      });
    });
    $( modal_skeleton ).modal({
      keyboard: true,
      backdrop: "static",
      show: true
    });
  } );
  $(".collections .delete").bind( 'click', function(e){
    var elem = $(".collections_list").find(".active");
    if(!!elem){
      alert("Please choose a collection to delete.");
      return false;
    }
    var data_source = elem.children().attr("data-source");
    app.ax({
      url: data_source,
      type: "DELETE",
      success: function(data){
        console.log("DELETED: " + JSON.stringify(data));
        $(elem).remove();
      }
    });
  } );
  $(".collections .add").bind( 'click', function(e){
    $("#modal_skeleton.modal").remove();
    var db = app.storage.get("database");
    var modal_skeleton = app.html.modal_skeleton.create( "modal_skeleton" );
    var input_field = app.html.template.input_field
    modal_skeleton.children[0].children = [
      { tag: "H3", text: "Add a Collection" }
    ];
    modal_skeleton.children[1].children = [
      input_field.container({
        id: "collection_name",
        name: "collection_name",
        text: "Name",
        placeholder: "Collection Name",
        size: "30"
      })
    ];
    modal_skeleton.children[2].children = [
      { tag: "A", cls: "btn primary", text: "Add" }
    ]
    $( "#modal_skeleton a" ).live("click", function(e){
      $( "#modal_skeleton" ).modal('hide');
      app.ax({
        url: "/database/" + db + "/collection",
        data: { collection_name: $("#collection_name").val() },
        success: function(data){
          if(data["created"]){
            $(".collections_list table tbody").append("<tr><td data-source='/database/"+db+"/collection/"+data["name"]+"'>"+data["name"]+"</td></tr>")
          }
        }
      });
    });
    $( modal_skeleton ).modal({
      keyboard: true,
      backdrop: "static",
      show: true
    });
  } );
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
app.html.modal_skeleton = {
  selector: "",
  clear: function(){
    $( this._el() ).remove();
  },
  create: function( anchor ){
    this.selector = anchor;
    this.clear();
    return(
      { tag: "DIV", id: anchor, style: "display:none", cls: "modal hide fade", children: [
        { tag: "DIV", cls: "modal-header" },
        { tag: "DIV", cls: "modal-body" },
        { tag: "DIV", cls: "modal-footer" }
      ] }
    )
  },
  _el: function(){
    return $(this.selector);
  }
}