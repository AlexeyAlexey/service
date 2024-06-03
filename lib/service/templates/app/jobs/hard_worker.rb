module Jobs
  class HardWorker
    include Sidekiq::Worker

    def perform(*args)
      ServiceApp.logger.info "#{self.class.name} job"
    end
  end
end
