require 'rails_helper'
require 'csp'

RSpec.describe Schedule::Strategies do
  let(:user_2_stars) { double(User, stars: 2) }
  let(:user_3_stars) { double(User, stars: 3) }
  let(:user_10_stars) { double(User, stars: 10) }

  let(:csp) { CSP::Solver::Problem.new }
  let(:users) { [user_2_stars, user_3_stars, user_10_stars] }

  context 'with strategies' do
    context 'with strict_schedule strategy' do
      context 'with possible values' do
        it 'returns an ideal solution' do
          csp.vars(0..5, users)
          strats = Schedule::Strategies.new(csp, users, 5)
          strats.strict_schedule
          response = csp.solve
          expect(response).to be_a Hash
          expect(response.values).to contain_exactly(
            user_2_stars, user_3_stars, user_3_stars,
            user_10_stars, user_10_stars, user_10_stars
          )
        end
      end

      context 'with impossible star values' do
        let(:user_10_stars) { double(User, stars: 1) }
        it 'returns false' do
          csp.vars(0..5, users)
          strats = Schedule::Strategies.new(csp, users, 5)
          strats.strict_schedule
          response = csp.solve
          expect(response).to be false
        end
      end

      context 'with too few slots' do
        it 'returns false' do
          csp.vars(0..4, users)
          strats = Schedule::Strategies.new(csp, users, 4)
          strats.strict_schedule
          response = csp.solve
          expect(response).to be false
        end
      end
    end

    context 'with leniently_weighted_schedule strategy' do
      context 'with possible values' do
        it 'returns an ideal solution' do
          csp.vars(0..5, users)
          strats = Schedule::Strategies.new(csp, users, 5)
          strats.leniently_weighted_schedule
          response = csp.solve
          expect(response).to be_a Hash
          expect(response.values).to contain_exactly(
            user_2_stars, user_3_stars, user_3_stars,
            user_10_stars, user_10_stars, user_10_stars
          )
        end
      end

      context 'with impossible star values' do
        let(:user_10_stars) { double(User, stars: 1) }
        it 'returns false' do
          csp.vars(0..5, users)
          strats = Schedule::Strategies.new(csp, users, 5)
          strats.leniently_weighted_schedule
          response = csp.solve
          expect(response).to be false
        end
      end

      context 'with too few slots' do
        it 'returns all users' do
          csp.vars(0..4, users)
          strats = Schedule::Strategies.new(csp, users, 4)
          strats.leniently_weighted_schedule
          response = csp.solve
          expect(response).to be_a Hash
          expect(response.values).to include user_10_stars
          expect(response.values).to include user_2_stars
          expect(response.values).to include user_3_stars
        end
      end
    end

    context 'with leniently_schedule strategy' do
      context 'with difficult values' do
        let(:user_10_stars) { double(User, stars: 1) }
        it 'returns a solution' do
          csp.vars(0..2, users)
          strats = Schedule::Strategies.new(csp, users, 2)
          strats.schedule_all_users
          response = csp.solve
          expect(response).to be_a Hash
          expect(response.values.count).to eq 3
          expect(response.values).to contain_exactly(user_2_stars, user_3_stars, user_10_stars)
        end
      end
    end
  end

  context 'with constraints' do
    context 'with schedule_all_users constraint' do
      context 'with too few slots' do
        it 'returns false' do
          csp.vars(0..1, users)
          strats = Schedule::Strategies.new(csp, users, 1)
          strats.schedule_all_users
          expect(csp.solve).to be false
        end
      end

      context 'with enough slots' do
        it 'contains all three users' do
          csp.vars(0..2, users)
          strats = Schedule::Strategies.new(csp, users, 2)
          strats.schedule_all_users
          response = csp.solve
          expect(response).to be_a Hash
          expect(response.values.count).to eq 3
          expect(response.values).to contain_exactly(user_2_stars, user_3_stars, user_10_stars)
        end
      end
    end

    context 'with strictly_weight_users constraint' do
      context 'with too few slots' do
        it 'returns false' do
          # Three users needs 6 slots, but we only have 5
          csp.vars(0..4, users)
          strats = Schedule::Strategies.new(csp, users, 4)
          strats.strictly_weight_users
          strats.schedule_all_users
          expect(csp.solve).to be false
        end
      end

      context 'with enough slots' do
        it 'contains users in the correct proportion' do
          csp.vars(0..5, users)
          strats = Schedule::Strategies.new(csp, users, 5)
          strats.strictly_weight_users
          strats.schedule_all_users
          response = csp.solve
          expect(response).to be_a Hash
          expect(response.values.count).to eq 6
          expect(response.values).to contain_exactly(
            user_2_stars, user_3_stars, user_3_stars,
            user_10_stars, user_10_stars, user_10_stars
          )
        end
      end
    end

    context 'with leniently_weight_users constraint' do
      context 'with too few slots' do
        it 'returns users' do
          # Three users needs 6 slots for strict weighting, but we only have 3
          csp.vars(0..2, users)
          strats = Schedule::Strategies.new(csp, users, 2)
          strats.leniently_weight_users
          strats.schedule_all_users
          result = csp.solve
          expect(result).to be_a Hash
          expect(result.values.count).to eq 3
        end
      end

      context 'with enough slots' do
        it 'contains users in the correct proportion' do
          csp.vars(0..5, users)
          strats = Schedule::Strategies.new(csp, users, 5)
          strats.strictly_weight_users
          strats.schedule_all_users
          response = csp.solve
          expect(response).to be_a Hash
          expect(response.values.count).to eq 6
          expect(response.values).to contain_exactly(
            user_2_stars, user_3_stars, user_3_stars,
            user_10_stars, user_10_stars, user_10_stars
          )
        end
      end
    end

    context 'with avoid_adjacent_similar_stars constraint' do
      context 'with an unsolvable set of users' do
        let(:user_10_stars) { double(User, stars: 1) }
        it 'returns false' do
          csp.vars(0..2, users)
          strats = Schedule::Strategies.new(csp, users, 2)
          strats.avoid_adjacent_similar_stars
          strats.schedule_all_users
          expect(csp.solve).to be false
        end
      end
      context 'with a solvable set of users' do
        it 'pushes users apart with similar star values' do
          csp.vars(0..2, users)
          strats = Schedule::Strategies.new(csp, users, 2)
          strats.avoid_adjacent_similar_stars
          strats.schedule_all_users
          response = csp.solve
          expect(response).to be_a Hash
          expect(response.values.map(&:stars)).to eq [2, 10, 3]
        end
      end
    end
  end
end
