module Released
  class Runner
    # FIXME: extract UI

    class TUI
      def initialize(io)
        @io = io
      end

      def move_up(num)
        @io <<
          if num == 1
            "\e[A"
          else
            "\e[#{num}A"
          end
      end

      def move_down(num)
        @io <<
          if num == 1
            "\e[B"
          else
            "\e[#{num}B"
          end
      end

      def move_to_left(col = 1)
        @io <<
          if col == 1
            "\e[G"
          else
            "\e[#{col}G"
          end
      end

      def clear_to_end_of_line
        @io << "\e[K"
      end
    end

    def initialize(goals, dry_run: false)
      @goals = goals
      @dry_run = dry_run

      @tui = TUI.new($stdout)
      @tui_mutex = Mutex.new
    end

    def run
      assess_all
      try_achieve_all
    end

    private

    def print_goals
      # Create space
      @goals.each { puts }
      @tui.move_up(@goals.size)

      @goals.each do |goal|
        left.times { $stdout << '. ' }

        @tui.move_to_left
        $stdout << goal
        $stdout << ' '

        @tui.move_to_left(left - 1)
        $stdout << ' '

        @tui.move_to_left
        @tui.move_down(1)
      end
    end

    def handle_error(e)
      puts
      puts 'FAILURE!'
      puts '-----'
      puts e.message
      puts
      puts e.backtrace.join("\n")
      puts '-----'
      puts 'Aborting!'
    end

    def write_state(idx, left, state)
      up = @goals.size - idx
      @tui.move_up(up)
      @tui.move_to_left(left)
      $stdout << state
      @tui.clear_to_end_of_line
      @tui.move_to_left
      @tui.move_down(up)
    end

    def left
      @_left ||= @goals.map { |g| g.to_s.size }.max + 5
    end

    def assess_all
      puts 'Assessing goals…'
      print_goals

      @goals.each.with_index do |_, idx|
        write_state(idx, left, 'waiting')
      end

      @goals.each.with_index do |goal, idx|
        if goal.assessable?
          write_state(idx, left, 'working…')

          begin
            goal.assess
            write_state(idx, left, 'ok (succeeded)')
          rescue => e
            write_state(idx, left, 'failed')
            handle_error(e)
            exit 1 # FIXME: eww
          end
        else
          write_state(idx, left, 'ok (skipped)')
        end
      end

      puts
    end

    def try_achieve_all
      puts 'Achieving goals…'
      print_goals

      @goals.each.with_index do |_, idx|
        write_state(idx, left, 'waiting')
      end

      @goals.each.with_index do |goal, idx|
        if @dry_run
          if goal.achieved?
            write_state(idx, left, 'ok (already achieved)')
          else
            write_state(idx, left, 'pending: ' + goal.failure_reason)
          end
          next
        end

        if goal.achieved?
          write_state(idx, left, 'ok (already achieved)')
          next
        end

        begin
          write_state(idx, left, 'working…')
          goal.try_achieve
        rescue => e
          write_state(idx, left, 'errored')
          handle_error(e)
          exit 1 # FIXME: eww
        end

        if !goal.effectful?
          write_state(idx, left, 'ok (passed)')
          next
        elsif goal.achieved?
          write_state(idx, left, 'ok (newly achieved)')
          next
        else
          write_state(idx, left, 'failed: ' + goal.failure_reason)
          puts
          puts 'Failed!'
          exit 1 # FIXME: eww
        end
      end
    end
  end
end
