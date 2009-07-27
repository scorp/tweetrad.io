(function(){
  window.tr = {};
  
  
  ///////////////////////
  // Server Connection //
  ///////////////////////
  tr.server = function(){
    var endpoint = '/tweets.json';
    
    return {
      /**
      * 
      **/
      fetch : function(query){
        new Ajax.Request(endpoint,{
          method      : 'post',
          parameters  : {
            json      : Object.toJSON({
                          twids : tr.data.twidsFor(query),
                          query : query
                        })
          },
          onSuccess   : this.onSuccess.bind(this, query),
          onFailure   : this.onFailure.bind(this, query),
          onException : this.onException.bind(this, query)
        });
      },

      /**
      * success
      **/
      onSuccess : function(query, transport){
        tr.data.store(query, transport.responseJSON);
      },

      /**
      * failure connecting to server
      **/
      onFailure : function(query, transport){
        // handle failure
        console.log('server failure');
      },

      /**
      * exception occured
      **/
      onException : function(query, transport){
        // handle exception
        console.log('exception');
      }
    };
  }();
  
  
  /////////////////
  // Tweet Store //
  /////////////////
  tr.data = function(){
    
    // hash of hashes for storing query stores
    var _h = new Hash();
    
    return {
      /**
      * get a query store
      **/
      get : function(query){
        var qs = _h.get(query);
        if (!qs) qs = _h.set(query, new Hash());
        return qs;
      },
      
      /**
      * store response json
      **/
      store : function(query, json){
        var qs = this.get(query);
        json.each(function(t){
          var tweet = {
            last_modfied : Date.parse(t.last_modified),
            meta_data    : t.tweet,
            url          : t.url,
            twid         : t.tweet.twid
          };
          if (!qs.get(tweet.twid)) {
            qs.set(tweet.twid, tweet);
          }
        }.bind(this));
      },
      
      /**
      * return the twids for a given query
      **/
      twidsFor : function(query){
        this.get(query).keys();
      },
      
      /**
      * return the tweets for a query ordered by date
      **/
      unplayedTweetsForQuery : function(query){
        var qs = this.get(query);
        return qs.values().select(
          function(tweet){
            return !tweet.played;
        })
        .sortBy(
          function(tweet){
            return tweet.lastModified;
        });
      },
      
      /**
      * return the next tweet for a given query
      **/
      nextTweetForQuery : function(query){
        
      }
      
    };
  }();
  
  
  ///////////
  // tweet //
  ///////////
  tr.tweet = function(){
    return {
      /**
      * extend an object as a tweet
      **/
      extend : function(object){
        Object.extend(object, this.methods);
      },
      
      /**
      * utilty methods for tweets
      **/
      methods : {
        
        
        
      }
    };
  }();
  
  
  ////////////////
  // MP3 Player //
  ////////////////
  tr.player = function(){
    return {
      
      /**
      * 
      **/
      setQuery : function(query){
        this.query = query;
      },
      
      /**
      * play the next track
      **/
      play : function(){
        console.log('starting play loop');
        if (!this.query) {
          setTimeout(this.play.bind(this), 1000);
        }
        var tweets = tr.data.unplayedTweetsForQuery(this.query);
        var _play = function(tweet){
          console.log(tweet);
          Sound.play(tweet.url, {replace : true});
          tweet.played = true;
          tweet = tweets.pop();
          if (tweet) {
            setTimeout(_play.bind(this, tweet), 7500);
          } else {
            setTimeout(this.play.bind(this), 1000);
          }
        }.bind(this);
        tweet = tweets.pop();
        _play(tweet);
      }
    };
  }();

}());