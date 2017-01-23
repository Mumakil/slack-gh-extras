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
        FactoryGirl.build(:slack_command, text: 'default set listname repo1')
      ).to be_valid
    end

    it 'works with clear action' do
      expect(
        FactoryGirl.build(:slack_command, text: 'default clear')
      ).to be_valid
    end

    it 'works without action' do
      expect(
        FactoryGirl.build(:slack_command, text: 'default')
      ).to be_valid
    end

    it 'fails others' do
      expect(
        FactoryGirl.build(:slack_command, text: 'default foobar')
      ).not_to be_valid
    end
  end

  describe '#process!' do

    describe 'listing' do
      context 'without default' do
        subject { FactoryGirl.build(:slack_command, text: 'default') }

        it 'does mostly nothing' do
          expect(subject.process!).to match('No default repositories')
        end
      end

      context 'with existing default' do
        let!(:channel) { FactoryGirl.create(:channel) }
        subject do
          FactoryGirl.build(
            :slack_command,
            channel_id: channel.slack_id,
            channel_name: channel.name,
            text: 'default'
          )
        end

        it 'prints out default' do
          res = subject.process!
          expect(res).to match('Default repositories for this channel')
          expect(res).to match(channel.default_repositories)
        end
      end
    end

    describe 'clearing' do
      context 'without existing default' do
        subject { FactoryGirl.build(:slack_command, text: 'default clear') }

        it 'does nothing' do
          expect(subject.process!).to match('No default repositories')
        end
      end

      context 'with existing default' do
        let!(:channel) { FactoryGirl.create(:channel) }
        subject do
          FactoryGirl.build(
            :slack_command,
            channel_id: channel.slack_id,
            channel_name: channel.name,
            text: 'default clear'
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
            text: 'default set foobar org/myrepo'
          )
        end

        it 'updates channel default' do
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
            text: 'default set foobar org/myrepo'
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
