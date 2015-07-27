# Irrelevant parts of this class have been omitted for clarity

class Team

    # This method applies our league's tie-breaking rules to determine which
    # of two teams should be ranked higher. It's used by the League model when
    # it updates its standings.
    def <=>(other_team)
        # Test 1: Winning Percentage
        wp_diff = self.winning_percentage <=> other_team.winning_percentage
        return wp_diff unless wp_diff == 0

        
        # Prepare some head-to-head stats for tests #2 and #3
        self_wins = 0
        other_team_wins = 0
        h2h_point_diff = 0
        
        # Loop over all of the games these two teams have played against each other
        Game.where({game_time: {'$lte' => Time.now}, '$and' => [{teams: self.id},{teams: other_team.id}]}).each do |g|
            self_wins += 1 if g.winning_team == self
            other_team_wins += 1 if g.winning_team == other_team
            h2h_point_diff += g.score_for(self).to_i - g.score_for(other_team).to_i
        end
        
        # Test 2: Head to Head Record
        h2h_win_diff = self_wins <=> other_team_wins
        return h2h_win_diff unless h2h_win_diff == 0

        # Test 3: Head-to-head point diff
        return h2h_point_diff <=> 0 unless h2h_point_diff == 0

        # Test 4: Overall point differential
        return self.point_diff <=> other_team.point_diff
    end
end
