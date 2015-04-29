class Deploy < Event
  def self.deploys_for_app(app_name)
    where("details ->> 'app_name' = '#{app_name}'")
  end
end
