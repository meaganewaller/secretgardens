require 'rails_helper'

RSpec.describe Profile, type: :model do
  subject { build(:profile) }

  it 'has a valid factory' do
    expect(subject).to be_valid
  end

  describe 'ActiveModel validations' do
    it { expect(subject).to validate_presence_of(:user_id) }
  end
end
