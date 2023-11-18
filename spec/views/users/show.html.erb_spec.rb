require 'rails_helper'

RSpec.describe 'users/show', type: :view do
  before(:each) do
    assign(:user, User.new(
      name: 'Name',
      stars: 2022
    ))
  end

  it "renders attributes in <p>" do
    render
    expect(rendered).to match(/Name/)
    expect(rendered).to match(/2022/)
  end
end
