module DDReleaser
  class Runner
    def initialize(stages)
      @stages = stages
    end

    def run
      assess_all
      achieve_all
    end

    private

    def assess_all
      puts '*** Assessing goals…'
      puts
      @stages.each do |stage|
        puts "#{stage.name}:"

        stage.goals.each do |goal|
          next unless goal.asses?

          print "  #{goal}… "

          res = goal.asses_safe

          if res.success?
            puts 'ok'
          else
            puts 'error'
            puts
            puts 'FAILURE!'
            puts '-----'
            puts res.reason
            puts '-----'
            puts 'Aborting!'
            exit 1
          end
        end
      end
      puts
    end

    def achieve_all
      puts '*** Achieving goals…'
      puts
      @stages.each do |stage|
        puts "#{stage.name}:"

        stage.goals.each do |goal|
          print "  #{goal}… "

          res = goal.achieve

          if res.success?
            puts 'ok'
          else
            puts 'error'
            puts
            puts 'FAILURE!'
            puts '-----'
            puts res.reason
            puts '-----'
            puts 'Aborting!'
            exit 1
          end
        end
      end
      puts

      puts 'Finished! :)'
    end
  end
end
