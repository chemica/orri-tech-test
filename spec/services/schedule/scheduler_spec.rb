require 'rails_helper'
require 'csp'

RSpec.describe Schedule::Scheduler do
  let(:strat) { instance_double('Schedule::Strategies') }
  let(:strategies) { class_double('Schedule::Strategies', new: strat) }

  describe '#update_imports' do
    context 'with enough slots for the strict strategy' do
      it 'should call the strict strategy' do
      end

      it 'should fail over to the leniently weighted strategy' do
      end

      it 'should fail over to the lenient strategy' do
      end
    end

    context 'without enough slots for the strict strategy' do
      it 'should not call the strict strategy' do
      end

      it 'should call the leniently weighted strategy' do
      end
    end

    context 'with a valid schedule' do
      it 'should insert new users into the database' do
      end

      it 'should overwrite users in the database' do
      end
    end
  end
end
