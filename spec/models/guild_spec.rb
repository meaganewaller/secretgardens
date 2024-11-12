require 'rails_helper'

RSpec.describe Guild, type: :model do
  let(:guild) { create(:guild) }

  describe "validations" do
    describe "builtin validations" do
      subject { guild }

      it { is_expected.to have_many(:blog_posts).dependent(:nullify) }
      it { is_expected.to have_many(:guild_memberships).dependent(:delete_all) }
      it { is_expected.to have_many(:users).through(:guild_memberships) }

      it { is_expected.to validate_length_of(:name).is_at_most(50) }
    end
  end
end
