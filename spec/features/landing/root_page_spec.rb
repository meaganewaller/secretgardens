require 'rails_helper'

feature 'Root page', js: true do
  before do
    visit root_path
  end

  scenario 'Root page should work' do
    expect(page).to have_text 'Contact'
    expect(page).to have_text 'Log in'
    expect(page).to have_text 'Sign up'

    expect(page).to_not have_text 'Log out'
  end
end
