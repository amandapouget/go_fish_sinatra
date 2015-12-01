require 'spec_helper'

describe MatchClientNotifier do
  let(:match) { create(:match) }
  let(:notifier) { match.match_client_notifier }

  it 'pushes notification to subscribers when match updates' do
    allow(notifier).to receive(:send_notice)
    expect(notifier).to receive(:send_notice)
    match.notify_observers
  end
end
