require 'csp'

module Schedule
  # A service object to update the import slots with users based on
  # required weighting and constraints.
  class Scheduler
    # Maxing out at 5 slots, as any more causes an error in the library
    def initialize(total_slots = 5)
      @upper_slot = total_slots - 1
      @total_slots = total_slots
    end

    def update_imports
      schedule = generate_schedule
      update_slots(schedule)
    end

    def update_slots(schedule)
      schedule.each do |hour, user|
        import_slot = ImportSlot.find_or_create_by(hour:)
        import_slot.update!(user:)
      end
    end

    def generate_schedule
      # If there's only one user, just schedule them for every hour
      return fill_import_slots if weighted_users.count == 1

      # Only apply this strategy if it has a chance of working
      if weighted_slot_count(weighted_users.count) <= @total_slots
        schedule = Strategies.apply_strategy(:strict_schedule, weighted_users, @upper_slot)
        return schedule if schedule
      end

      schedule = Strategies.apply_strategy(:leniently_weighted_schedule, weighted_users, @upper_slot)
      return schedule if schedule

      schedule = Strategies.apply_strategy(:lenient_schedule, weighted_users, @upper_slot)
      return schedule if schedule

      raise 'Unable to generate a schedule'
    end

    private

    def fill_import_slots
      arr = (0..@upper_slot).map { |i| [i, weighted_users[0]] }
      arr.to_h
    end

    # Memoized users ordered by increasing weight
    def weighted_users
      @weighted_users ||= User.weighted_users(@total_slots)
    end

    def weighted_slot_count(users)
      users * (users + 1) / 2
    end
  end
end
