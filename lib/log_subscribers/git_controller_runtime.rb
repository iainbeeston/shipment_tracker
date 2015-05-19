module LogSubscribers
  module GitControllerRuntime
    extend ActiveSupport::Concern

    protected

    attr_internal :git_runtime_before_render
    attr_internal :git_runtime_during_render

    def cleanup_view_runtime
      self.git_runtime_before_render = GitSubscriber.reset_runtime
      runtime = super
      self.git_runtime_during_render = GitSubscriber.reset_runtime
      runtime - git_runtime_during_render
    end

    def append_info_to_payload(payload)
      super
      payload[:git_runtime] = (git_runtime_before_render || 0) +
                              (git_runtime_during_render || 0) +
                              GitSubscriber.reset_runtime
    end

    module ClassMethods
      def log_process_action(payload)
        messages = super
        git_runtime = payload[:git_runtime]
        messages << format('Git: %.1fms', git_runtime) if git_runtime
        messages
      end
    end
  end
end
