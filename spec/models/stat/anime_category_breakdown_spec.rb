# rubocop:disable Metrics/LineLength
# == Schema Information
#
# Table name: stats
#
#  id         :integer          not null, primary key
#  stats_data :jsonb            not null
#  type       :string           not null, indexed => [user_id]
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  user_id    :integer          not null, indexed => [type], indexed
#
# Indexes
#
#  index_stats_on_type_and_user_id  (type,user_id) UNIQUE
#  index_stats_on_user_id           (user_id)
#
# Foreign Keys
#
#  fk_rails_9e94901167  (user_id => users.id)
#
# rubocop:enable Metrics/LineLength

require 'rails_helper'

RSpec.describe Stat::AnimeCategoryBreakdown do
  let(:user) { create(:user) }
  let(:anime) { create(:anime, :categories) }
  let(:le) { create(:library_entry, user: user, anime: anime, progress: 1) }

  before do
    Stat::AnimeCategoryBreakdown.increment(user, le)
    user.stats.find_or_initialize_by(type: 'Stat::AnimeCategoryBreakdown').recalculate!
  end

  describe '#recalculate!' do
    it 'should create Stat' do
      stat = Stat.find_by(user: user, type: 'Stat::AnimeCategoryBreakdown')

      expect(stat.stats_data).to_not be_nil
    end
  end

  describe '#self.increment' do
    it 'should have 5 total' do
      record = Stat.find_by(user: user, type: 'Stat::AnimeCategoryBreakdown')

      expect(record.stats_data['total']).to eq(5)
      expect(record.stats_data['total_media']).to eq(1)
    end
  end

  describe '#self.decrement' do
    before do
      Stat::AnimeCategoryBreakdown.decrement(user, le)
    end
    it 'should have 0 total' do
      record = Stat.find_by(user: user, type: 'Stat::AnimeCategoryBreakdown')

      expect(record.stats_data['total']).to eq(0)
      expect(record.stats_data['total_media']).to eq(0)
    end
  end
end
