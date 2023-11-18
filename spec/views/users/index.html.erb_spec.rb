require 'rails_helper'

RSpec.describe 'users/index', type: :view do
  before(:each) do
    assign(:users, [
             UserDetail.new(
               id: 1,
               name: 'Name',
               language_count: 1001,
               repository_count: 1002,
               stars: 2022
             ),
             UserDetail.new(
               id: 2,
               name: 'Name2',
               language_count: 1001,
               repository_count: 1002,
               stars: 2022
             )
           ])
  end

  it 'renders a list of users' do
    render
    cell_selector = Rails::VERSION::STRING >= '7' ? 'div>p' : 'tr>td'
    assert_select cell_selector, text: Regexp.new('Name'.to_s), count: 2
    assert_select cell_selector, text: Regexp.new(2022.to_s), count: 2
    assert_select cell_selector, text: Regexp.new(1001.to_s), count: 2
    assert_select cell_selector, text: Regexp.new(1002.to_s), count: 2
  end
end
