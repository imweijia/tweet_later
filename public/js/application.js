$(document).ready(function() {
  // This is called after the document has loaded in its entirety
  // This guarantees that any elements we bind to will exist on the page
  // when we try to bind to them

$("#tweet_form").submit(function( event ) {
    var tweet_text = $('#tweet_text').val();
    var url = $(this).attr('action');

    $.ajax({
      type: "POST",
      url: url,
      data: { tweet: tweet_text },
      beforeSend: function() {
        $('#tweet_loader').html("<center><img src='/gifs/ajax-loader.gif'></center>")
        $('#tweet_button').attr('disabled', 'disabled');
        $('#tweet_text').attr('disabled', 'disabled');
      },
      success: function(data) {
        // console.log(data);
        $('#tweet_loader').hide();
        $('.container').html(data);
        $('#tweet_button').removeAttr('disabled', 'disabled');
        $('#tweet_text').removeAttr('disabled', 'disabled');
      }
    });
    event.preventDefault();
  });

  function check_job_status(job_id)
  {
    $.ajax (
    {
      type: "GET",
      url: '/status/' + job_id
    });
    request.done(function(response)
      if (response === 'true')
      {
        $('#status').html('Done');
      }
      else
      {
        setTimeout(function(){check_job_status(job_id)}, 10000)
      }
    }
};
    $("#post_tweet_later").submit(function(event)
    {
      console.log("test2")
      $('#status').show();
      $("#wait-msg").show();
      var postData = $(this).serializeArray();
      alert("postData");
      $.ajax(
      {
        url : '/tweet_later',
        type: "POST",
        data : postData,
        success:function(result)
        {

          $("#status").html('Tweeting...');
          setTimeout(function(){ check_job_status(result) }, 10000);
          document.getElementById("post_tweet_later").reset();
          populate_tweets();
        },
        error: function(jqXHR, textStatus, errorThrown)
        {
          $("#status").html('Tweet Failed');
        }
      });
      event.preventDefault(); //STOP default action
    });

});


