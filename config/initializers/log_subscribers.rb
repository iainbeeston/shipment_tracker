require 'log_subscribers/git_subscriber'
require 'log_subscribers/git_controller_runtime'

LogSubscribers::GitSubscriber.attach_to :git

ActiveSupport.on_load(:action_controller) do
  include LogSubscribers::GitControllerRuntime
end
