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

    def assessing_goal_ended(_goal)
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

    def achieving_goal_ended_not_effectful(_goal)
      puts format_success_new('ok')
    end

    def achieving_goal_ended_pending(goal)
      puts format_pending('pending')
    end

    def achieving_goal_ended_not_achieved(goal)
      puts format_failure('failed')
      puts "    reason: #{goal.failure_reason}"
    end

    def achieving_goal_ended_already_achieved(_goal)
      puts format_success_old('ok (already achieved)')
    end

    def achieving_goal_ended_newly_achieved(_goal)
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

    ORANGE       = "\e[38;5;208m".freeze
    RED          = "\e[38;5;196m".freeze
    DARK_GREEN   = "\e[38;5;28m".freeze
    BRIGHT_GREEN = "\e[38;5;40m".freeze
    BLUE         = "\e[38;5;27m".freeze
    YELLOW       = "\e[38;5;220m".freeze
    RESET        = "\e[0m".freeze

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

    def format_pending(s)
      YELLOW + s + RESET
    end

    def format_error(s)
      RED + s + RESET
    end
  end
end
