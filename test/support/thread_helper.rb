module ThreadHelper
  def sleep_to_force_race_condition
    sleep rand / 10.0 # 0.0Xs delays to minimize active delays while ensuring race conditions
  end

  # Solid Queue boots processes inside the thread spawned by #start, so
  # registration is not visible the moment #start returns.
  def wait_until_registered(process, timeout: 5.seconds)
    deadline = Process.clock_gettime(Process::CLOCK_MONOTONIC) + timeout

    until process.process_id.present?
      if Process.clock_gettime(Process::CLOCK_MONOTONIC) > deadline
        raise "#{process.class} did not register within #{timeout.inspect}"
      end

      sleep 0.01
    end
  end
end
