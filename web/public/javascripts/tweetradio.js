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
          parameters  : Object.toJSON({
            twids     : tr.data.twidsFor(query),
            query     : query
          }),
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
      },

      /**
      * exception occured
      **/
      onException : function(query, transport){
        // handle exception
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
        debugger;
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
        qs.values().select(
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
        if (!this.query) {
          setTimeout(this.play.bind(this), 1000);
        }
        var tweets = tr.data.unplayedTweetsForQuery(this.query);
        while (tweet = tweets.pop()) {
          console.log(tweet);
          tweet.played = true;
        };
        setTimeout(this.play.bind(this), 1000);
      }
    };
  }();

}());