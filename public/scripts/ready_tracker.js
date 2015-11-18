function ReadyTracker() {
}

ReadyTracker.prototype.setReadyOn = function() {
  var pageReady = document.createElement('div');
  pageReady.id = 'ready';
  document.body.appendChild(pageReady);
}

ReadyTracker.prototype.setReadyOff = function() {
  var pageReady = document.getElementById('ready');
  if (pageReady) {
    pageReady.remove();
  }
}
