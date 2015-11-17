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

PlayerView.prototype.setMessage = function(message) {
  document.getElementById('message').innerText = message;
}

PlayerView.prototype.setScores = function(scores) {
  var scoreDiv = document.getElementById('scores');
  while (scoreDiv.firstChild) {
      scoreDiv.removeChild(scoreDiv.firstChild);
  }
  scores.forEach( function(score) {
    var h4 = document.createElement("h4");
    var node = document.createTextNode(score[0] + ": " + score[1]);
    h4.appendChild(node);
    scoreDiv.appendChild(h4);
  });
}

PlayerView.prototype.setBooks = function(books) {
  var booksDiv = document.getElementById('books');
  var num_books_to_add = books.length - booksDiv.children.length + 1;
  var book = document.createElement("img");
  book.src = "/images/cards/backs_blue.png";
  for (i = 0; i < num_books_to_add; i++) {
    booksDiv.appendChild(book);
  }
}

PlayerView.prototype.setCards = function(cards) {
  var oldCardElements = Array.prototype.slice.call(document.getElementsByClassName('your-cards'));
  oldCardElements.forEach(function(element) {
    element.remove();
  });
  var playerDiv = document.getElementById('player');
  cards.forEach( function(card, index) {
    var newCard = document.createElement("img");
    newCard.className = 'your-cards';
    newCard.src = card.icon;
    newCard.id = "card_" + index;
    newCard.value = card.rank_value;
    newCard.name = card.rank;
    playerDiv.appendChild(newCard);
  }.bind(this));
  var newCardElements = Array.prototype.slice.call(document.getElementsByClassName('your-cards'));
  newCardElements.forEach( function(cardElement, index) {
    cardElement.onclick = function() {
      this.rank = cardElement.name;
      console.log("Rank selected: " + this.rank);
    }.bind(this);
  }.bind(this));
}

PlayerView.prototype.refresh = function() {
  console.log("GOT REFRESH");
  $.ajax({
     url: '/' + this.match_id + '/player/' + this.player_num + '.json',
     dataType: 'json',
     complete: function(data){
     },
     success: function(data){
       var playerInfo = JSON.parse(data);
       this.setBooks(playerInfo.player_books);
       this.setScores(playerInfo.scores);
       this.setMessage(playerInfo.message);
       this.setCards(playerInfo.player_cards);
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
  var pusher = new Pusher('39cc3ae7664f69e97e12', { encrypted: true });
  var channel = pusher.subscribe('game_play_channel_' + playerView.match_id);
  channel.bind('pusher:subscription_succeeded', playerView.refresh.bind(playerView));
  channel.bind('refresh_event', playerView.refresh.bind(playerView));
});
