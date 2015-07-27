# Irrelevant parts of this class have been omitted for clarity

class League
    # There's a bug in this method:
    #   Typically when there are ties, the tied teams get the
    #   same rank, but we skip as many ranks as there are tied
    #   teams. So if two teams tie for first place, the next
    #   Next team after those would be ranked 3rd. The method
    #   below would show the first two teams ranked as 1st and
    #   the third team ranked as 2nd.
    
    def update_standings!
        # Update stats and sort the league
        team_cache = teams.to_a
        
        # There's a custom sort method on the Team model
        team_cache.each { |t| t.update_stats }.sort!.reverse!

        rank = 0
        team_cache.each_with_index do |this_team, order|
            rank += 1 unless (this_team <=> team_cache[order-1]) == 0

            this_team.league_rank = rank
            this_team.save
        end
    end
end
