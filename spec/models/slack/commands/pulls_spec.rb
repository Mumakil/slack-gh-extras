# frozen_string_literal: true

require 'rails_helper'
require 'slack_helper'

RSpec.describe Slack::Commands::Pulls, type: :model do

  before do
    slack_test_configuration!
  end

  describe '#process!' do

    describe 'without user' do
      subject { FactoryGirl.build(:slack_command, text: 'prs foo/bar1') }

      it 'returns an error' do
        expect do
          expect(subject.process!).to match("You haven't set GitHub access token")
        end.not_to have_enqueued_job(PullRequestsJob)
      end
    end

    describe 'using default' do

      let(:user) { FactoryGirl.create(:user) }

      context 'with default set' do
        let(:repository_names) { FactoryGirl.generate_list(:repository_name, 2) }
        let(:list) { FactoryGirl.create(:repo_list, :with_repositories) }
        let(:defaults) { repository_names.dup.concat([list.name]) }
        let(:channel) do
          FactoryGirl.create(
            :channel,
            default_repositories: defaults.join(' ')
          )
        end
        subject do
          FactoryGirl.build(
            :slack_command,
            text: 'prs',
            user_id: user.slack_id,
            channel_id: channel.slack_id
          )
        end

        it 'finds the default' do
          expect { subject.process! }.to have_enqueued_job(PullRequestsJob).with(
            repository_names.dup.concat(list.repositories.pluck(:name)),
            channel.default_repositories.split(' '),
            user.id,
            subject.response_url
          )
        end
      end

      context 'without default' do
        subject do
          FactoryGirl.build(
            :slack_command,
            text: 'prs',
            user_id: user.slack_id
          )
        end

        it 'returns error' do
          expect do
            expect(subject.process!).to match('no default for this channel')
          end.not_to have_enqueued_job(PullRequestsJob)
        end
      end
    end

    describe 'resolving lists' do

      let(:user) { FactoryGirl.create(:user) }
      let(:repository_names) { FactoryGirl.generate_list(:repository_name, 2) }
      let(:lists) do
        FactoryGirl.create_list(:repo_list, 2, :with_repositories, repo_count: 3)
      end
      subject do
        FactoryGirl.build(
          :slack_command,
          text: "prs #{repository_names.join(' ')} #{lists.map(&:name).join(' ')} foobar #{repository_names.first}",
          user_id: user.slack_id
        )
      end

      it 'resolves all lists and ignores bogus ones' do
        expect do
          subject.process!
        end.to have_enqueued_job(PullRequestsJob).with(
          [
            repository_names,
            lists.first.repositories.pluck(:name),
            lists.second.repositories.pluck(:name)
          ].flatten,
          [
            repository_names,
            lists.map(&:name),
            'foobar',
            repository_names.first
          ].flatten,
          user.id,
          subject.response_url
        )
      end
    end
  end
end
