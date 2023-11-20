require 'csp'

module Schedule
  # A service object to update the import slots with users based on
  # required weighting and constraints.
  class Scheduler
    def initialize(total_slots = 24, strategies_class = Strategies)
      @upper_slot = total_slots - 1
      @total_slots = total_slots
      @strategies_class = strategies_class
    end

    def update_imports
      schedule = generate_schedule

      schedule.each do |position, user|
        import_slot = ImportSlot.find_or_create_by(position:)
        import_slot.update!(user:)
      end
    end

    # Strategies

    private

    def generate_schedule
      if weighted_slot_count(weighted_users.count) <= @total_slots
        schedule = apply_strategy(:strict_schedule)
        return schedule if schedule
      end

      schedule = apply_strategy(:leniently_weighted_schedule)
      return schedule if schedule

      schedule = apply_strategy(:lenient_schedule)
      return schedule if schedule

      raise 'Unable to generate a schedule'
    end

    def apply_strategy(strategy)
      raise "#{strategy} strategy doesn't exist" unless Strategies.STRATS.include?(strategy)

      csp = CSP::Solver::Problem.new
      # Set the variables: one for each hour of the day.
      csp.vars(0..@upper_slot, weighted_users)
      strats = @strategies_class.new(csp, weighted_users, @upper_slot)
      strats.call strategy
      csp.solve
    end

    # Memoized users ordered by increasing weight
    def weighted_users
      @weighted_users ||=
        all_users.map { |user| [user, user_weight(user)] }
                 .sort_by(&:last)
                 .map(&:first)
    end

    def all_users
      User.includes(:language_users, :languages, :repositories)
          .order(created_at: :desc)
          .first(@total_slots) # More than this will cause the scheduling constraints to fail
    end

    def weighted_slot_count(users)
      users * (users + 1) / 2
    end
  end
end
