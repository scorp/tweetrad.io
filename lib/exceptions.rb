class InvalidQueryException < Exception; @message = "invalid query provided"; end
class QueueRequired < Exception; @message = "invalid query provided"; end
class JobRequired < Exception; @message = "job required"; end