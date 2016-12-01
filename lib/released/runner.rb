module Released
  class Runner
    def initialize(goals, dry_run: false, ui: Released::RunnerUI.new)
      @goals = goals
      @dry_run = dry_run
      @ui = ui
    end

    def run
      assess_all
      try_achieve_all
    end

    private

    def assess_all
      @ui.assessing_started
      goals.each do |goal|
        next unless goal.assessable?

        @ui.assessing_goal_started(goal)

        begin
          goal.assess
        rescue => e
          @ui.errored(e)
          exit 1 # FIXME: eww
        end

        @ui.assessing_goal_ended(goal)
      end
      @ui.assessing_ended
    end

    def try_achieve_all
      @ui.achieving_started
      goals.each do |goal|
        @ui.achieving_goal_started(goal)

        if @dry_run
          if goal.achieved?
            @ui.achieving_goal_ended_already_achieved(goal)
          else
            @ui.achieving_goal_ended_pending(goal)
          end
          next
        end

        if goal.achieved?
          @ui.achieving_goal_ended_already_achieved(goal)
          next
        end

        begin
          goal.try_achieve
        rescue => e
          @ui.errored(e)
          exit 1 # FIXME: eww
        end

        if !goal.effectful?
          @ui.achieving_goal_ended_not_effectful(goal)
          next
        elsif goal.achieved?
          @ui.achieving_goal_ended_newly_achieved(goal)
          next
        else
          @ui.achieving_goal_ended_not_achieved(goal)
          exit 1 # FIXME: eww
        end
      end
      @ui.achieving_ended
    end
  end
end
