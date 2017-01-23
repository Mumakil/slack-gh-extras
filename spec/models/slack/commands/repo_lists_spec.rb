# frozen_string_literal: true

require 'rails_helper'
require 'slack_helper'

RSpec.describe Slack::Commands::RepoLists, type: :model do

  before do
    slack_test_configuration!
  end

  describe 'validations' do
    it 'works with add action' do
      expect(
        FactoryGirl.build(:slack_command, text: 'list add listname repo1')
      ).to be_valid
    end

    it 'works with remove action' do
      expect(
        FactoryGirl.build(:slack_command, text: 'list remove listname repo1')
      ).to be_valid
    end

    it 'works without action' do
      expect(
        FactoryGirl.build(:slack_command, text: 'list')
      ).to be_valid
    end

    it 'fails others' do
      expect(
        FactoryGirl.build(:slack_command, text: 'list foobar')
      ).not_to be_valid
    end
  end

  describe '#process!' do

    describe 'listing' do

      subject { FactoryGirl.build(:slack_command, text: 'list') }

      context 'without existing lists' do
        it 'does mostly nothing' do
          expect(subject.process!).to match('Nobody has created any repository lists')
        end
      end

      context 'with existing lists' do
        let!(:lists) { FactoryGirl.create_list(:repo_list, 5, :with_repositories) }

        it 'prints out lists' do
          res = subject.process!
          expect(res).to match(lists.first.name + ':')
          expect(res).to match(lists.last.repositories.first.name)
        end
      end
    end

    describe 'adding to lists' do
      context 'when the list does not exist' do
        subject do
          FactoryGirl.build(
            :slack_command,
            text: 'list add newlist org/repo1 org/repo2 foobar'
          )
        end

        it 'creates new repository list' do
          expect do
            subject.process!
          end.to change(RepoList, :count).by(1)
        end

        it 'adds valid repositories' do
          expect do
            subject.process!
          end.to change(Repository, :count).by(2)
        end

        it 'prints out list' do
          res = subject.process!
          expect(res).to match('org/repo1')
          expect(res).to match('newlist:')
        end
      end

      context 'when the list already exists' do
        let!(:list) { FactoryGirl.create(:repo_list, :with_repositories)}
        let(:existing_repo) { list.repositories.first }

        subject do
          FactoryGirl.build(
            :slack_command,
            text: "list add #{list.name} #{existing_repo.name} neworg/name1 otherord/name2"
          )
        end

        it 'does not create new list' do
          expect do
            subject.process!
          end.not_to change(RepoList, :count)
        end

        it 'adds valid repositories' do
          expect do
            subject.process!
          end.to change(list.repositories, :count).by(2)
        end

        it 'prints out new list state' do
          res = subject.process!
          expect(res).to match(list.name + ':')
          expect(res).to match('neworg/name1')
        end
      end
    end

    describe 'removing from lists' do
      context 'when the list does not exist' do

        subject do
          FactoryGirl.build(
            :slack_command,
            text: 'list remove foobar org/repo'
          )
        end

        it 'prints out a neat message' do
          expect(subject.process!).to match('No such list.')
        end
      end

      context 'when the list exists' do

        let!(:list) { FactoryGirl.create(:repo_list, :with_repositories) }

        context 'when the list becomes empty' do
          subject do
            FactoryGirl.build(
              :slack_command,
              text: "list remove #{list.name} #{list.repositories.map(&:name).join(' ')}"
            )
          end

          it 'deletes the repositories' do
            expect do
              subject.process!
            end.to change(Repository, :count).by(-list.repositories.size)
          end

          it 'deletes the list' do
            expect do
              subject.process!
            end.to change(RepoList, :count).by(-1)
          end

          it 'tells it deleted the list' do
            expect(subject.process!).to match('list has been deleted')
          end
        end

        context 'when there are remaining entries in the list' do
          subject do
            FactoryGirl.build(
              :slack_command,
              text: "list remove #{list.name} foobar #{list.repositories.first.name}"
            )
          end

          it 'deletes the repositories' do
            expect do
              subject.process!
            end.to change(list.repositories, :count).by(-1)
          end

          it 'does not touch the list itself' do
            expect do
              subject.process!
            end.not_to change(RepoList, :count)
          end

          it 'prints out current list' do
            res = subject.process!
            expect(res).to match(list.name + ':')
            expect(res).to match(list.repositories.last.name)
          end
        end
      end
    end
  end
end
