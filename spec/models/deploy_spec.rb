describe Deploy do
  describe ".deploys_for_app" do
    let(:my_app_name) { 'hello_world_app' }

    before { Deploy.create(details: { app_name: 'other_app' }) }

    context "when deploy events exist for app" do
      let!(:deploys_for_my_app) do
        2.times.collect { Deploy.create(details: { app_name: my_app_name }) }
      end

      it "returns all deploy events for app" do
        expect(Deploy.deploys_for_app(my_app_name)).to match_array(deploys_for_my_app)
      end
    end

    context "when deploy events do not exist for app" do
      it "returns empty" do
        expect(Deploy.deploys_for_app(my_app_name)).to be_empty
      end
    end
  end
end
