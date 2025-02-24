module Delayed
  class Worker
    class JobManager
      def ps_tag
        Digest::MD5.hexdigest(Rails.root.to_s)[0..8]
      end

      def exec_env
        { "RAILS_ENV" => Rails.env }
      end

      def workers
        # Synchronous read for jobs
        all_jobs = `ps aux`.split("\n")
        running = all_jobs.select { |line| line =~ /delayed_job/ && line =~ /#{ps_tag}/ }
        running.size
      end

      def start
        cmd_args = "script/delayed_job start -i #{ps_tag}".split
        IO.popen([exec_env] + cmd_args)
      end

      def stop
        cmd_args = "script/delayed_job stop -i #{ps_tag}".split
        IO.popen([exec_env] + cmd_args)
      end
    end
  end
end
