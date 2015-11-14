function PlayerView(match_id, player_num, player_object_id) {
  this.match_id = match_id;
  this.player_num = player_num;
  this.player_object_id = player_object_id;
  this.listenForOpponentSelection();
  this.listenForRankRequest();
}

PlayerView.prototype.listenForOpponentSelection = function() {
  var object = this;
  $(".opponents .player").each(function(index) {
    $(this).click(function() {
      object.opponent_object_id = $(this).attr("data-value");
      var opponent_name = $(this).attr("name");
      console.log("Opponent selected: " + opponent_name);
    });
  });
}

PlayerView.prototype.listenForRankRequest = function() {
  var object = this;
  $("#fish_blue").click(function(){
    if (object.rank && object.opponent_object_id) {
      $.post('/' + object.match_id + '/card_request', { player_object_id: object.player_object_id, opponent_object_id: object.opponent_object_id, rank: object.rank }).success(function()  {
        console.log('Card request info sent!');
      });
    }
  }.bind(this));
}

PlayerView.prototype.setCards = function(cards) {
  var elements = Array.prototype.slice.call(document.getElementsByClassName('your-cards'));
  elements.forEach(function(element) {
    element.remove();
  });
  var player_div = document.getElementById('player');
  cards.forEach( function(card, index) {
    new_card = document.createElement("img");
    new_card.className = 'your-cards';
    new_card.src = card.icon;
    new_card.id = "card_" + index;
    new_card.value = card.rank_value;
    new_card.name = card.rank;
    player_div.appendChild(new_card);
    new_card.onclick = function() {
      this.rank = new_card.name;
      console.log("Rank selected: " + this.rank);
    }.bind(this);
  }.bind(this));
}

PlayerView.prototype.refresh = function() {
  console.log("GOT REFRESH");
  $.ajax({
     url: 'http://localhost:4567/' + this.match_id + '/player/' + this.player_num + '.json',
     dataType: 'json',
     complete: function(data){
     },
     success: function(data){
       var cards = data;
       this.setCards(cards);
       console.log("SUCCESSFUL");
     }.bind(this),
     error: function(data, text_status, error_thrown){
       console.log(data, text_status, error_thrown);
     },
  });
};

$(document).ready(function() {
  var match_id = window.location.pathname.split('/')[1];
  var player_num = window.location.pathname.split('/')[3];
  var player_object_id = $(".info-for-player .player").attr("value");
  var playerView = new PlayerView(match_id, player_num, player_object_id);
  playerView.refresh(); // Do it the first time


  Pusher.log = function(message) {
    if (window.console && window.console.log) {
      window.console.log(message);
    }
  };
  var pusher = new Pusher('39cc3ae7664f69e97e12', { encrypted: true });
  var channel = pusher.subscribe('game_play_channel_' + playerView.match_id);

  channel.bind('refresh_event', playerView.refresh.bind(playerView));
});
