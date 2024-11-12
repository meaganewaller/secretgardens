require 'rails_helper'

RSpec.describe Profile, type: :model do
  let(:user) { create(:user) }
  subject { build(:profile, user:) }

  it 'has a valid factory' do
    expect(subject).to be_valid
  end

  describe 'ActiveModel validations' do
    it { expect(subject).to validate_presence_of(:user_id) }
  end
end
