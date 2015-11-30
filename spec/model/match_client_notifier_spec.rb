require 'spec_helper'

describe MatchClientNotifier do
  let(:match) { create(:match) }
  let(:notifier) { match.match_client_notifier }

  it 'pushes notification to subscribers when match updates' do
    allow(notifier).to receive(:after_save)
    expect(notifier).to receive(:after_save)
    match.save
  end
end
