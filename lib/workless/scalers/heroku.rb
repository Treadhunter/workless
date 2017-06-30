#require 'heroku-api'
require 'platform-api'

module Delayed
  module Workless
    module Scaler

      class Heroku < Base

        extend Delayed::Workless::Scaler::HerokuClient

        def self.up
          #client.put_workers(ENV['APP_NAME'], 1) if self.workers == 0
          #client.formation.update(ENV['APP_NAME'], '{"quantity": 1, "size": "standard-1X", "XXX": "workers")
          client.formation.update(ENV['APP_NAME'], 'worker', {size: 'standard-1X', quantity: 1}) if self.workers == 0
        end

        def self.down
          # client.put_workers(ENV['APP_NAME'], 0) unless self.jobs.count > 0 or self.workers == 0
          client.formation.update(ENV['APP_NAME'], 'worker', {size: 'standard-1X', quantity: 0}) unless self.jobs.count > 0 or self.workers == 0
        end

        def self.workers
          # client.get_ps(ENV['APP_NAME']).body.count { |p| p["process"] =~ /worker\.\d?/ }
          worker_list = client.formation.list(ENV['APP_NAME']).select{|h| h["type"]=="worker"}
          if worker_list.nil?
            return 0
          else
            return worker_list.first["quantity"]
          end
        end

      end

    end
  end
end
