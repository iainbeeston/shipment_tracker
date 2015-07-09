class Token < ActiveRecord::Base
  has_secure_token :value

  def self.valid?(source, token)
    token.present? && exists?(source: source, value: token)
  end

  def self.revoke(id)
    find(id).destroy
  end

  def source_name
    EventTypeRepository.from_rails_config.find_by_endpoint(source).name
  end
end
