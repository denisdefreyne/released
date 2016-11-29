module Released
  class RunnerUI
    def assessing_started
      puts '*** Assessing goals…'
      puts
    end

    def assessing_ended
      puts
    end

    def assessing_stage_started(stage)
      puts "#{format_stage(stage.name)}:"
    end

    def assessing_stage_ended(stage)
    end

    def assessing_goal_started(goal)
      print "  #{goal}… "
    end

    def assessing_goal_ended(goal)
      puts 'ok'
    end

    def achieving_started
      puts '*** Achieving goals…'
      puts
    end

    def achieving_ended
      puts
      puts 'Finished! :)'
    end

    def achieving_stage_started(stage)
      puts "#{format_stage(stage.name)}:"
    end

    def achieving_stage_ended(stage)
    end

    def achieving_goal_started(goal)
      print "  #{goal}… "
    end

    def achieving_goal_ended_not_effectful(goal)
      puts format_success_new('ok')
    end

    def achieving_goal_ended_not_achieved(goal)
      puts format_failure('failed')
      puts "    reason: #{goal.failure_reason}"
    end

    def achieving_goal_ended_already_achieved(goal)
      puts format_success_old('ok (already achieved)')
    end

    def achieving_goal_ended_newly_achieved(goal)
      puts format_success_new('ok (newly achieved)')
    end

    def errored(e)
      puts format_error('error')
      puts
      puts 'FAILURE!'
      puts '-----'
      puts e.message
      puts
      puts e.backtrace.join("\n")
      puts '-----'
      puts 'Aborting!'
    end

    private

    ORANGE       = "\e[38;5;208m"
    RED          = "\e[38;5;196m"
    DARK_GREEN   = "\e[38;5;28m"
    BRIGHT_GREEN = "\e[38;5;40m"
    BLUE         = "\e[38;5;27m"
    RESET        = "\e[0m"

    def format_stage(s)
      BLUE + s + RESET
    end

    def format_success_old(s)
      DARK_GREEN + s + RESET
    end

    def format_success_new(s)
      BRIGHT_GREEN + s + RESET
    end

    def format_failure(s)
      ORANGE + s + RESET
    end

    def format_error(s)
      RED + s + RESET
    end
  end
end
