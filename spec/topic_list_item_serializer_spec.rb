# frozen_string_literal: true

RSpec.describe TopicListItemSerializer do
  let!(:topic) { Fabricate(:topic) }
  let!(:post) { Fabricate(:post, topic: topic) }
  let!(:reply) do
    Fabricate(:post, topic: topic, raw: "A reply to the <a href=\"example.com\">topic</a>")
  end

  before(:each) do
    SiteSetting.highest_post_enabled = true
  end

  it "serializes highest_post excerpt" do
    Topic.reset_all_highest!
    topic.reload
    serialized = TopicListItemSerializer.new(topic, scope: Guardian.new, root: false).as_json
    expect(serialized[:highest_post_number]).to eq(reply.post_number)
    expect(serialized[:highest_post_excerpt]).to eq("A reply to the topic")
  end
  it "removes links" do
    Topic.reset_all_highest!
    topic.reload
    serialized = TopicListItemSerializer.new(topic, scope: Guardian.new, root: false).as_json
    expect(reply.excerpt).to include("<")
    expect(serialized[:highest_post_excerpt]).to eq("A reply to the topic")
  end

  context "when disabled" do
    before(:each) do
      SiteSetting.highest_post_enabled = false
    end
    it "doesn't serialize highest_post excerpt" do
      Topic.reset_all_highest!
      topic.reload
      serialized = TopicListItemSerializer.new(topic, scope: Guardian.new, root: false).as_json
      expect(serialized[:highest_post_number]).to eq(reply.post_number)
      expect(serialized[:highest_post_excerpt]).to be_nil
    end
  end
end
