# Some complexity has been removed from this class for clarity

class GameCancellationWorker
  include Sidekiq::Worker

  def perform(league_id, fieldsite_id, start_ts, end_ts)
    # Make sure all of this stuff exists:
    league = League.find(league_id)
    raise "League not found for #{league_id}" unless league.present?

    @fieldsite = FieldSite.find(fieldsite_id)
    raise "Field Site not found for #{fieldsite_id}" unless @fieldsite.present?

    # Find the games that match the query we're looking for
    games_to_cancel = league.games.where(field_site: @fieldsite, :game_time.gte => start_ts, :game_time.lte => end_ts)

    # Cache the teams so that we don't have to load them multiple times
    teams = {}
    games_to_cancel.each do |game|
        next if game.rained_out?
        
        game.rainout!
        game.teams.each do |t|
            teams[t._id] ||= t unless notify == :nobody
        end
    end

    # Cache the payers so we don't have to load them multiple times
    player_list = {}
    teams.each do |team_id, team|
        team.players.each do |u|
            player_list[u._id] ||= u
        end
    end

    # Notify the players
    game_date     = Time.at(start_ts).strftime('%a, %b %e')
    text_message  = "Bad news! Your AFDC games at #{@fieldsite.name} are cancelled for today (#{game_date})."

    player_list.each do |user_id, p|
        logger.info("Notifying #{p.name}")
        notify_user(p, text_message, start_ts)
    end
  end

  def notify_user(user, text_message, game_day_timestamp)
    user.notification_methods.each do |nm|
        next unless nm.enabled?

        if nm.method == 'text'
            twilio_client = Twilio::REST::Client.new
            twilio_client.account.messages.create({ 
                from: ENV['twilio_number'], 
                to:   nm.target,
                body: text_message
            })
        end

        if nm.method == 'email'
            NotificationMailer.games_cancelled(nm._id, @fieldsite._id, game_day_timestamp).deliver
        end
    end
  end
end
