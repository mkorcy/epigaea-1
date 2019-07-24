
var DraftControls = createReactClass({

  render: function() {
    return <div>
           <DraftSaveButton curationConcernId={this.props.curationConcernId} draftSaved={this.props.draftSaved}></DraftSaveButton>
           </div>
  }
});
