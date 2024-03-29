require 'rails_helper'

RSpec.describe User, type: :model do
  subject(:user) { build(:user) }

  it { is_expected.to be_valid }

  describe 'validations' do
    it { is_expected.to validate_presence_of(:email) }
    it { is_expected.to allow_value('james+test@snowball.is').for(:email) }
    it { is_expected.to_not allow_value('foo').for(:email) }
    it 'validates the email as unique and case sensitive' do
      user.save!
      user2 = build(:user, email: user.email.upcase)
      expect(user2.valid?).to be_falsey
    end

    it { is_expected.to validate_presence_of(:username) }
    it 'validates the username as unique and case sensitive' do
      user.save!
      user2 = build(:user, username: user.username.upcase)
      expect(user2.valid?).to be_falsey
    end
    it { is_expected.to validate_length_of(:username).is_at_least(3) }
    it { is_expected.to allow_value('abc').for(:username) }
    it { is_expected.to_not allow_value('@@@').for(:username) }
    it { is_expected.to_not allow_value('...').for(:username) }
    it { is_expected.to_not allow_value('a').for(:username) }
    it { is_expected.to_not allow_value('test test').for(:username) }

    it { is_expected.to validate_length_of(:password).is_at_least(5) }
    it 'validates presence of :password' do
      user = build(:user, password: nil)
      expect(user).to validate_presence_of(:password)
    end

    # TODO: Phone number validation specs

    it 'validates presence of :auth_token' do
      allow(user).to receive(:generate_auth_token)
      expect(user).to validate_presence_of(:auth_token)
    end

    it { is_expected.to validate_attachment_content_type(:avatar) }
  end

  describe 'associations' do
    it { is_expected.to have_many(:clips).dependent(:destroy) }
    it { is_expected.to have_many(:followings).class_name('Follow').dependent(:destroy) }
    it { is_expected.to have_many(:follows).class_name('Follow').dependent(:destroy) }
    it { is_expected.to have_many(:likes).dependent(:destroy) }
    it { is_expected.to have_many(:devices).dependent(:destroy) }
  end

  describe 'before_validation(on: :create)' do
    it 'generates a new auth token' do
      expect(user).to receive(:generate_auth_token)
      user.valid?
    end
  end

  describe 'after_create' do
    it 'follows the snowball user' do
      expect(user).to receive(:follow_snowball)
      user.save!
    end
    it 'follows the snowboard user' do
      expect(user).to receive(:follow_snowboard)
      user.save!
    end
  end

  # describe 'before_post_process' do
  #   it 'renames the avatar file name' do
  #     expect(user).to receive(:change_avatar_filename)
  #     user.save!
  #   end
  # end

  describe '#generate_auth_token' do
    it 'generates a new auth token' do
      # TODO: bring back regex validation here
      # regex = '^(?:[A-Za-z0-9+/]{4})*(?:[A-Za-z0-9+/]{2}==|[A-Za-z0-9+/]{3}=)?$'
      # expect { user.save }.to change { user.auth_token }.from(nil).to(a_string_matching(regex))
      expect(user.auth_token).to be_nil
      user.save!
      expect(user.auth_token).to_not be_nil
    end
  end

  describe '#follow_snowball' do
    context 'when the snowball account exists' do
      it 'follows the snowball account' do
        user2 = create(:user, email: 'hello@snowball.is')
        expect { user.save }.to change { user.follows.count }.from(0).to(1)
        expect(user.following?(user2)).to be_truthy
      end
    end
  end

  describe '#follow_snowboard' do
    context 'when the snowboard account exists' do
      it 'follows the snowboard account' do
        user2 = create(:user, email: 'onboarding@snowball.is')
        expect { user.save }.to change { user.follows.count }.from(0).to(1)
        expect(user.following?(user2)).to be_truthy
      end
    end
  end

  # describe '#change_avatar_filename' do
  #   it 'changes the avatar file name' do
  #   end
  # end

  describe '#following?(user)' do
    it 'returns true if the user is following the user' do
      follow = create(:follow)
      expect(follow.follower.following?(follow.following)).to be_truthy
    end
    it 'returns false if the user is not following the user' do
      user = create(:user)
      user2 = create(:user)
      expect(user.following?(user2)).to be_falsy
    end
  end

  describe '#follow(user)' do
    before(:each) do
      user.save!
    end
    it 'follows the specified user' do
      user2 = create(:user)
      expect(user.follows.count).to eq(0)
      user.follow(user2)
      expect(user.following?(user2)).to be_truthy
    end
    it 'does not follow a user duplicate times' do
      user2 = create(:user)
      user.follow(user2)
      expect(user.follows.count).to eq(1)
      user.follow(user2)
      expect(user.follows.count).to eq(1)
    end
    it 'does not follow self' do
      expect(user.follows.count).to eq(0)
      user.follow(user)
      expect(user.follows.count).to eq(0)
    end
  end

  describe '#unfollow(user)' do
    before(:each) do
      user.save!
    end
    it 'unfollows the specified user' do
      user2 = create(:user)
      user.follow(user2)
      expect(user.follows.count).to eq(1)
      user.unfollow(user2)
      expect(user.follows.count).to eq(0)
    end
  end
end
