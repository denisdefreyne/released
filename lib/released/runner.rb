module Released
  class Runner
    def initialize(stages, ui: Released::RunnerUI.new)
      @stages = stages
      @ui = ui
    end

    def run
      assess_all
      try_achieve_all
    end

    private

    def assess_all
      @ui.assessing_started
      @stages.each do |stage|
        @ui.assessing_stage_started(stage)
        stage.goals.each do |goal|
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
        @ui.assessing_stage_ended(stage)
      end
      @ui.assessing_ended
    end

    def try_achieve_all
      @ui.achieving_started
      @stages.each do |stage|
        @ui.achieving_stage_started(stage)

        stage.goals.each do |goal|
          @ui.achieving_goal_started(goal)

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
      end
      @ui.achieving_ended
    end
  end
end
