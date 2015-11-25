function PlayerView(match_id, player_index) {
  this.match_id = match_id;
  this.player_index = player_index;
  this.listenForRankRequest();
}

PlayerView.prototype.listenForOpponentSelection = function() {
  var object = this;
  $('.opponents .player').each(function(index) {
    $(this).click(function() {
      object.opponent_index = $(this).attr('data-player-index');
      console.log('Opponent selected: ' + object.opponent_index);
    });
  });
}

PlayerView.prototype.listenForRankRequest = function() {
  var object = this;
  $('#fish_blue').click(function(){
    console.log('/' + object.match_id + '/card_request', { player_index: object.player_index, opponent_index: object.opponent_index, rank: object.rank });
    if (object.rank && object.opponent_index) {
      $.post('/' + object.match_id + '/card_request', { player_index: object.player_index, opponent_index: object.opponent_index, rank: object.rank }).success(function()  {
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
    var h4 = document.createElement('h4');
    var node = document.createTextNode(score[0] + ': ' + score[1]);
    h4.appendChild(node);
    scoreDiv.appendChild(h4);
  });
}

PlayerView.prototype.setOpponents = function(opponents) {
  var opponentsDiv = document.getElementById('opponents');
  if (!opponentsDiv.hasChildNodes()) {
    opponents.forEach( function(opponent, index) {
      var opponentDiv = document.createElement('div');
      opponentDiv.className = "player";
      opponentDiv.id = "opponent_" + index;
      opponentDiv.setAttribute("data-player-index", opponent.index);
      opponentsDiv.appendChild(opponentDiv);
      this.insertPlayer(opponentDiv, opponent.name, opponent.icon);
      var book = document.createElement('img');
      book.src = '/images/cards/backs_blue.png';
      opponentDiv.appendChild(book);
    }.bind(this));
    this.listenForOpponentSelection();
  }
}

PlayerView.prototype.setPlayer = function(player) {
  var playerDiv = document.getElementById('player');
  if (!playerDiv.hasChildNodes()) {
    this.insertPlayer(playerDiv, player.name, player.icon);
  }
  this.setBooks(player.books);
  this.setCards(player.cards);
}

PlayerView.prototype.insertPlayer = function(div, playerName, playerIcon) {
  var h4 = document.createElement('h4');
  var node = document.createTextNode(playerName);
  h4.appendChild(node);
  div.appendChild(h4);
  var icon = document.createElement('img');
  icon.src = playerIcon;
  div.appendChild(icon);
}

PlayerView.prototype.setBooks = function(books) {
  var booksDiv = document.getElementById('books');
  var num_books_to_add = books.length - booksDiv.children.length + 1;
  var book = document.createElement('img');
  book.src = '/images/cards/backs_blue.png';
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
    var newCard = document.createElement('img');
    newCard.className = 'your-cards';
    newCard.src = card.icon;
    newCard.id = 'card_' + index;
    newCard.value = card.rank_value;
    newCard.name = card.rank;
    playerDiv.appendChild(newCard);
  }.bind(this));
  var newCardElements = Array.prototype.slice.call(document.getElementsByClassName('your-cards'));
  newCardElements.forEach( function(cardElement, index) {
    cardElement.onclick = function() {
      this.rank = cardElement.name;
      console.log('Rank selected: ' + this.rank);
    }.bind(this);
  }.bind(this));
}

PlayerView.prototype.refresh = function() {
  $.ajax({
     url: '/' + this.match_id + '/player/' + this.player_index + '.json',
     dataType: 'json',
     complete: function(data){
     },
     success: function(data){
       var gameInfo = JSON.parse(data);
       this.setMessage(gameInfo.message);
       this.setScores(gameInfo.scores);
       this.setOpponents(gameInfo.opponents);
       this.setPlayer(gameInfo.player);
     }.bind(this),
     error: function(data, text_status, error_thrown){
       console.log(data, text_status, error_thrown);
     },
  });
};

$(document).ready(function() {
  var readyTracker = new ReadyTracker();
  var match_id = window.location.pathname.split('/')[1];
  var player_index = window.location.pathname.split('/')[3];
  var playerView = new PlayerView(match_id, player_index);
  var pusher = new Pusher('39cc3ae7664f69e97e12', { encrypted: true });
  var channel = pusher.subscribe('game_play_channel_' + playerView.match_id);
  channel.bind('pusher:subscription_succeeded', function() {
    playerView.refresh();
    readyTracker.setReadyOn();
  });
  channel.bind('refresh_event', playerView.refresh.bind(playerView));
});
