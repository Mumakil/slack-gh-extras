# frozen_string_literal: true

require 'rails_helper'
require 'slack_helper'

RSpec.describe Slack::Commands::Defaults, type: :model do

  before do
    slack_test_configuration!
  end

  describe 'validations' do
    it 'works with set action' do
      expect(
        FactoryGirl.build(:slack_command, text: 'defaults set listname repo1')
      ).to be_valid
    end

    it 'works with clear action' do
      expect(
        FactoryGirl.build(:slack_command, text: 'defaults clear')
      ).to be_valid
    end

    it 'works without action' do
      expect(
        FactoryGirl.build(:slack_command, text: 'defaults')
      ).to be_valid
    end

    it 'fails others' do
      expect(
        FactoryGirl.build(:slack_command, text: 'defaults foobar')
      ).not_to be_valid
    end
  end

  describe '#process!' do

    describe 'listing' do
      context 'without defaults' do
        subject { FactoryGirl.build(:slack_command, text: 'defaults') }

        it 'does mostly nothing' do
          expect(subject.process!).to match('No default repositories')
        end
      end

      context 'with existing defaults' do
        let!(:channel) { FactoryGirl.create(:channel) }
        subject do
          FactoryGirl.build(
            :slack_command,
            channel_id: channel.slack_id,
            channel_name: channel.name,
            text: 'defaults'
          )
        end

        it 'prints out defaults' do
          res = subject.process!
          expect(res).to match('Default repositories for this channel')
          expect(res).to match(channel.default_repositories)
        end
      end
    end

    describe 'clearing' do
      context 'without existing defaults' do
        subject { FactoryGirl.build(:slack_command, text: 'defaults clear') }

        it 'does nothing' do
          expect(subject.process!).to match('No default repositories')
        end
      end

      context 'with existing defaults' do
        let!(:channel) { FactoryGirl.create(:channel) }
        subject do
          FactoryGirl.build(
            :slack_command,
            channel_id: channel.slack_id,
            channel_name: channel.name,
            text: 'defaults clear'
          )
        end

        it 'deletes channel data' do
          expect do
            subject.process!
          end.to change(Channel, :count).by(-1)
          expect(Channel.find_by_id(channel.id)).to be_nil
        end

        it 'notifies channel' do
          expect do
            subject.process!
          end.to have_enqueued_job(SlackNotifierJob)
        end
      end
    end

    describe 'setting' do
      context 'updating existing' do
        let!(:channel) { FactoryGirl.create(:channel) }
        subject do
          FactoryGirl.build(
            :slack_command,
            channel_id: channel.slack_id,
            channel_name: channel.name,
            text: 'defaults set foobar org/myrepo'
          )
        end

        it 'updates channel defaults' do
          subject.process!
          expect(channel.reload.default_repositories).to eq('foobar org/myrepo')
        end

        it 'notifies channel' do
          expect do
            subject.process!
          end.to have_enqueued_job(SlackNotifierJob)
        end
      end

      context 'creating new' do
        subject do
          FactoryGirl.build(
            :slack_command,
            :with_channel,
            text: 'defaults set foobar org/myrepo'
          )
        end

        it 'creates channel settings' do
          expect do
            subject.process!
          end.to change(Channel, :count).by(1)
        end

        it 'notifies channel' do
          expect do
            subject.process!
          end.to have_enqueued_job(SlackNotifierJob)
        end
      end
    end
  end
end
