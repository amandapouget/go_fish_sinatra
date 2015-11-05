$(document).ready(function() {
  var match_id = window.location.pathname.split('/')[1];

  Pusher.log = function(message) {
    if (window.console && window.console.log) {
      window.console.log(message);
    }
  };
  var pusher = new Pusher('39cc3ae7664f69e97e12', {
    encrypted: true
  });
  var channel = pusher.subscribe('game_play_channel_' + match_id);
  channel.bind('game_message_event', function(data) {
    document.getElementById("message").innerText = data["message"];
  });

  var rank, opponent_object_id, opponent_name;
  var player_name = $(".info-for-player .player").attr("name");
  var player_object_id = $(".info-for-player .player").attr("value");

  $(".your-cards").each(function(index) {
    $(this).click(function() {
      rank = $(this).attr("name");
      console.log("Rank selected: " + rank);
    });
  });

  $(".opponents .player").each(function(index) {
    $(this).click(function() {
      opponent_object_id = $(this).attr("data-value");
      opponent_name = $(this).attr("name");
      console.log("Opponent selected: " + opponent_name);
    });
  });

  $("#fish_blue").click(function(){
    // if it's your turn and you've clicked the right elements to define all these variables
    $.post('/' + match_id + '/game_notifications', { message: player_name + " asks " + opponent_name + " for " + rank }).success(function()  {
      console.log('Asking announcement sent!');
    });
    $.post('/' + match_id + '/card_request', { player_object_id: player_object_id, opponent_object_id: opponent_object_id, rank: rank }).success(function()  {
      console.log('Card request info sent!');
    });
    // will need to refresh cards
  });

});
