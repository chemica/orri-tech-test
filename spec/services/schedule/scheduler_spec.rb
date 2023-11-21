require 'rails_helper'
require 'csp'

RSpec.describe Schedule::Scheduler do
  let(:user1) { double(User, stars: 2) }
  let(:user2) { double(User, stars: 3) }
  let(:user3) { double(User, stars: 10) }

  let(:users) { [user1, user2, user3] }

  describe '#update_imports' do
    context 'with enough slots for the strict strategy' do
      it 'should call the strict strategy' do
        expect(Schedule::Strategies).to receive(:apply_strategy)
                                    .with(:strict_schedule, anything, anything).once.and_return users
        expect(Schedule::Strategies).not_to receive(:apply_strategy)
                                    .with(:leniently_weighted_schedule, anything, anything)
        expect(Schedule::Strategies).not_to receive(:apply_strategy)
                                    .with(:lenient_schedule, anything, anything)
        Schedule::Scheduler.new(3).generate_schedule
      end

      it 'should fail over to the leniently weighted strategy' do
        expect(Schedule::Strategies).to receive(:apply_strategy)
                                    .with(:strict_schedule, anything, anything).once.and_return false
        expect(Schedule::Strategies).to receive(:apply_strategy)
                                    .with(:leniently_weighted_schedule, anything, anything).once.and_return users
        expect(Schedule::Strategies).not_to receive(:apply_strategy)
                                    .with(:lenient_schedule, anything, anything)
        Schedule::Scheduler.new(3).generate_schedule
      end

      it 'should fail over to the lenient strategy' do
        expect(Schedule::Strategies).to receive(:apply_strategy)
                                    .with(:strict_schedule, anything, anything).once.and_return false
        expect(Schedule::Strategies).to receive(:apply_strategy)
                                    .with(:leniently_weighted_schedule, anything, anything).once.and_return false
        expect(Schedule::Strategies).to receive(:apply_strategy)
                                    .with(:lenient_schedule, anything, anything).once.and_return users
        Schedule::Scheduler.new(3).generate_schedule
      end
    end

    context 'with a valid schedule' do
      before do
        User.create!(name: 'aaa', stars: 2)
        User.create!(name: 'bbb', stars: 3)
        User.create!(name: 'ccc', stars: 10)
      end

      it 'should insert new slots into the database' do
        expect do
          Schedule::Scheduler.new(3).update_imports
        end.to change(ImportSlot, :count).by(3)
      end

      it 'should overwrite slots in the database' do
        Schedule::Scheduler.new(3).update_imports
        User.create!(name: 'ddd', stars: 10)
        User.create!(name: 'eee', stars: 20)
        User.create!(name: 'fff', stars: 40)
        expect do
          Schedule::Scheduler.new(3).update_imports
        end.to change(ImportSlot, :count).by(0)
        expect(ImportSlot.includes(:user).map { |s| s.user.stars }.sum).to eq 70
      end
    end
  end
end
