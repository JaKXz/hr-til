require 'rails_helper'

describe Developer do
  let(:developer) { FactoryGirl.build(:developer) }

  it 'should have a valid factory' do
    expect(developer).to be_valid
  end

  it 'should require a username' do
    developer.username = ''
    expect(developer).to_not be_valid
  end

  it 'should require an email' do
    developer.email = ''
    expect(developer).to_not be_valid
  end

  context 'validates email domains' do
    before do
      stub_const('ENV', {
        'permitted_domains' => 'hashrocket.com|hshrckt.com'
      })
    end

    it 'and allows whitelisted domains' do
      developer.email = 'foo@hashrocket.com'
      expect(developer).to be_valid
      developer.email = 'foo@hshrckt.com'
      expect(developer).to be_valid
    end

    it 'should deny an email from a non-whitelisted domain' do
      developer.email = 'foo@example.com'
      expect(developer).to_not be_valid
      expect(developer.errors.messages[:email]).to eq ['is invalid']
    end
  end

  it 'should validate username uniqueness' do
    FactoryGirl.create(:developer, username: developer.username)
    dup_developer = FactoryGirl.build(:developer, username: developer.username)
    expect(dup_developer).to_not be_valid
    expect(dup_developer.errors.messages[:username]).to eq ['has already been taken']
  end

  it 'should set admin as false on create' do
    expect(developer.admin).to eq false
  end

  context 'twitter username should be validated' do
    it 'should be alphanumeric' do
      developer.twitter_handle = 'abc...'
      expect(developer).to_not be_valid
    end

    it 'should not be all numbers' do
      developer.twitter_handle = '999'
      expect(developer).to_not be_valid
    end

    context 'is valid if it contains at least one alphabet character' do
      specify 'at the end' do
        developer.twitter_handle = '999a'
        expect(developer).to be_valid
      end

      specify 'at the beginning' do
        developer.twitter_handle = 'a999'
        expect(developer).to be_valid
      end
    end

    it 'should not be more than 15 characters' do
      developer.twitter_handle = 'a' * 16
      expect(developer).to_not be_valid
    end

    it 'should remove any leading @ symbols' do
      developer.twitter_handle = '@@@@hashrocket'
      expect(developer.twitter_handle).to eq 'hashrocket'
    end

    it 'should not allow blank' do
      developer.twitter_handle = ''
      expect(developer).to be_valid
      expect(developer.twitter_handle).to eq nil
    end

    context 'can contain an underscore' do
      specify 'as the leading character' do
        developer.twitter_handle = '_writer'
        expect(developer).to be_valid
      end

      specify 'anywhere else in the handle' do
        developer.twitter_handle = 'code_writer'
        expect(developer).to be_valid
      end
    end
  end

  describe "the slack display name" do
    it "returns the slack display name" do
      d = Developer.new(slack_name: "slackname")

      expect(d.slack_display_name).to eq("slackname")
    end

    it "returns the username if the slack name is nil" do
      d = Developer.new(slack_name: nil, username: "username")

      expect(d.slack_display_name).to eq("username")
    end

    it "returns the username if the slack name is blank" do
      d = Developer.new(slack_name: "", username: "username")

      expect(d.slack_display_name).to eq("username")
    end
  end
end
