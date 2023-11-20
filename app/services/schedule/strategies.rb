module Schedule
  # Implementation of constraint programming strategies
  class Strategies
    def initialize(csp, weighted_users, upper_slot = 23)
      @csp = csp
      @weighted_users = weighted_users
      @upper_slot = upper_slot
    end

    # Strategies

    STRATS = %i[strict_schedule leniently_weighted_schedule lenient_schedule].freeze

    def strict_schedule
      Rails.logger.info 'Setting up a strictly weighted schedule'
      schedule_all_users
      strictly_weight_users
      avoid_adjacent_similar_stars
    end

    def leniently_weighted_schedule
      Rails.logger.info 'Setting up a leniently weighted schedule'
      schedule_all_users
      leniently_weight_users
      avoid_adjacent_similar_stars
    end

    def lenient_schedule
      Rails.logger.info 'Setting up a lenient schedule'
      schedule_all_users
      leniently_weight_users
    end

    # Constraints

    def schedule_all_users
      # Each user must be scheduled at least once.
      @weighted_users.each do |user|
        @csp.constrain(*0..@upper_slot) do |*args|
          args.include?(user)
        end
      end
    end

    def strictly_weight_users
      # Users with a higher weight must be scheduled more often.
      @weighted_users.each_cons(2) do |u1, u2|
        @csp.constrain(*0..@upper_slot) do |*args|
          occurrences(args, u1) < occurrences(args, u2)
        end
      end
      # There must be at least one occurence of the least weighted user.
      @csp.constrain(*0..@upper_slot) do |*args|
        occurrences(args, @weighted_users[0]) == 1
      end
    end

    def leniently_weight_users
      # Users with a higher weights can be scheduled more often, but definitely not less
      # often than those with lower weights.
      @weighted_users.each_cons(2) do |u1, u2|
        @csp.constrain(*0..@upper_slot) do |*args|
          occurrences(args, u1) <= occurrences(args, u2)
        end
      end
      # There must be at least one occurence of the least weighted user.
      @csp.constrain(*0..@upper_slot) do |*args|
        occurrences(args, @weighted_users[0]) == 1
      end
    end

    def avoid_adjacent_similar_stars
      # Users with similar star counts must not be scheduled next to eachother.
      (0..@upper_slot).each_cons(2) do |v1, v2|
        @csp.constrain(v1, v2) do |u1, u2|
          dissimilar_stars?(u1, u2)
        end
      end
    end

    private

    # Count the occurrences of an element in an array
    def occurrences(arr, element)
      arr.select { |e| e == element }.count
    end

    def dissimilar_stars?(user1, user2)
      (user1.stars - user2.stars).abs > 2
    end
  end
end
