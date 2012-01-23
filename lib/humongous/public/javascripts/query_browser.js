app.html.query_browser = {
  selector: '.yielder',
  clear: function(){
    $( this._el() ).children().remove();
  },
  create: function(){
    this.clear();
    return(
      { tag: "DIV", cls: "query_browser", children: [
        { tag: "FORM", children: 
          [
            { tag: "FIELDSET", children: [
              // this._get_legend(),
              { tag: "DIV", cls: "input_row", children: [
                { tag: "DIV", cls: "query_form", children: [
                  { tag: "LABEL", "for": "query", text: "Query" },
                  { tag: "INPUT", type: "text", placeholder: "Find All", id: "query", size: "41", name: "query" }
                ] },
                { tag: "DIV", cls: "sort_form", children: [
                  { tag: "LABEL", "for": "sort", text: "Sort" },
                  { tag: "INPUT", type: "text", placeholder: "[\"name\", \"asc\"]", id: "sort", name: "sort" }
                ] },
                { tag: "DIV", cls: "clear" }
              ] },
              // { tag: "DIV", cls: "clear" },
              { tag: "DIV", cls: "input_row", children: [
                { tag: "DIV", cls: "fields_form", children: [
                  { tag: "LABEL", "for": "fields", text: "Fields" },
                  { tag: "INPUT", type: "text", placeholder: "field1, field2", id: "fields", size: "30", name: "fields" }
                ] },
                { tag: "DIV", cls: "skip_form", children: [
                  { tag: "LABEL", "for": "skip", text: "Skip" },
                  { tag: "INPUT", type: "text", placeholder: "0", id: "skip", size: "5", name: "skip", value: "0", cls: 'number' }
                ] },
                { tag: "DIV", cls: "limit_form", children: [
                  { tag: "LABEL", "for": "limit", text: "Limit" },
                  { tag: "INPUT", type: "text", placeholder: "10", id: "limit", size: "5", name: "limit", value: "10", cls: 'number' }
                ] },
                { tag: "INPUT", type: 'submit', cls: "submit_btn btn", value: "Search" },
                { tag: "DIV", cls: "clear" }
              ] }
            ] }
          ]
        },
        { tag: "DIV", cls: "query_result" },
        { tag: "DIV", id: "object_modal", "style": "display: none; ", cls: "modal hide fade", children: [
          { tag: "DIV", cls: "modal-header", children: [
            { tag: "A", cls: "close", href: "#", text: "x" },
            { tag: "H3", text: "Record" }
          ] },
          { tag: "DIV", cls: "modal-body", children: [
            { tag: "P", text: "One fine body." }
          ] },
          { tag: "DIV", cls: "modal-footer", children: [
            { tag: "A", cls: "btn primary", href: "#", text: "Save", onClick: this._submit.bind( this ) }
          ] }
        ] }
      ] }
    )
  },
  _el: function(){
    return $(this.selector);
  },
  _get_legend: function(){
    return(
      { tag: "LEGEND", text: "QueryBrowser" }
    )
  },
  _submit: function(e){
    var db = app.storage.get("database"), coll = app.storage.get("collection")
    var data = $(e.target).parent().siblings().find('TEXTAREA').val();
    app.ax({
      url: "/database/" + db + "/collection/" + coll + "/save",
      data: { "doc": JSON.parse(data)  },
      success: function( data ){
        console.log(data)
        $('#object_modal').modal('toggle');
      }
    })
  }
};
app.html.build_results = {
  selector: '.query_result',
  clear: function(){
    $( this._el() ).children().remove();
  },
  _el: function(){
    return $(this.selector);
  },
  create: function( mongo_obj ){
    this.clear();
    return(
      { tag: "TABLE", cls: "mongo_results zebra-striped", children: [
        { tag: "THEAD", children: [
          { tag: "TR", children: [
            { tag: "TH", text: "Name" },
            { tag: "TH", text: "Value" }
          ] }
        ] },
        { tag: "TBODY", children: this._get_rows( mongo_obj ) }
      ] }
    )
  },
  _get_rows: function( mongo_obj ){
    var res = [];
    var self = this
    $.each( mongo_obj, function( _, obj ){
      res.push(
         { tag: "TR", onClick: self._callback.bind( this ), id: obj["_id"], children: [
          { tag: "TD", text: "_id" },
          { tag: "TD", text: obj["_id"] }
         ] }
      )
    });
    return res;
  },
  _callback: function(e){
    var db = app.storage.get("database");
    var coll = app.storage.get("collection");
    $("#object_modal .modal-header H3").text(db + "." + coll + " (" + this._id + ")" );
    $("#object_modal .modal-body").children().remove();
    $( { tag: "TEXTAREA", style: "height: 200px; width: 520px", text: JSON.stringify( this, null, "\t")  } ).appendTo( '#object_modal .modal-body' );
    $('#object_modal').modal({
      keyboard: true,
      backdrop: "static",
      show: true
    });
  },
  _build_modal: function( object ){
    return(
      { tag: "TEXTAREA", text: JSON.stringify( object, null, "\t")  }
    )
  }
}
app.html.template.abstract_field = {
  val: function( value ){
    if( value ){
      return $( this._el() ).val( value );
    }else{
      return $( this._el() ).val();
    }
  },
  container: function( options ){
    return(
      { tag: "DIV", cls: "", children: [
        { tag: "LABEL", "for": options.id, text: options.text },
        { tag: "DIV", cls: "input", children: this._el_container( options ) }
      ] }
    )
  },
  _el: function(){
    return $( this._el_container() );
  },
};
app.html.template.input_field = app.merge( app.html.template.abstract_field, {
  _el_container: function( options ){
    return([
      { tag: "INPUT", type: "text", name: options.id, id: options.id, "placeholder": options.placeholder, size: options.size }
    ])
  }
});
app.html.template.select_field = app.merge( app.html.template.abstract_field, {
  _el_container: function( options ){
    return([
      { tag: "SELECT", name: options.name, id: options.id, children: this._option_builder( options ) }
    ])
  },
  _option_builder: function( options ){
    if( options.option_builder ){
      return options.option_builder.call();
    }else if( options.select_options ){
      return this._build_options( options.select_options )
    }else{
      return([
        { tag: "OPTION", val: "No Options provided", text: "No Options provided" }
      ])
    }
  },
  _build_options: function( select_options ){
    res = [];
    for( var key in select_options ){
      res.push({
        tag: "OPTION", val: key, text: select_options[key].to_String()
      });
    };
    return res;
  }
} );