# User Notifications by Text or Email

For a local rec-sports league's website, we send notifications by text or email
when a player's game is cancelled. We want to make them confirm the phone number
or email address in most cases. 

This sample demonstrates the use of asynchronous jobs and external APIs. 

## Architecture

Notification methods are created with a standard controller and view (not included).
On creation, confirmation messages are sent by a Sidekiq worker. The notification
method model is located in `models/notification_method.rb`. The confirmation worker
can be found in `workers/notification_confirmation_worker.rb`.

A league commissioner can rain out games by field site via the web interface.
When that happens, another asynchronous job handles marking the games as rained out
and then notifying players who have notification methods set. The game cancellations 
Sidekiq worker can be found in `workers/game_cancellation_worker.rb`. 

-----
The full rec-sports league repository is open source and 
[located on GitHub](https://github.com/AFDC/Platinum).
