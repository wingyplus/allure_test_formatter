defmodule AllureTestFormatter do
  @moduledoc """
  AllureTestFormatter is an ExUnit formatter that generates Allure test results.

  It implements the ExUnit.Formatter behaviour and receives events as GenServer casts
  to generate Allure-compatible test result files.
  """

  use GenServer

  @doc """
  Initializes the formatter with the given ExUnit configuration.
  """
  def init(opts) do
    File.mkdir_p!("allure-results")

    # Store configuration and initialize state
    state = %{
      config: opts,
      test_results: [],
      test_directory: "allure-results",
      current_test_result: nil
    }

    {:ok, state}
  end

  @doc """
  Handles ExUnit formatter events as GenServer casts.
  """
  def handle_cast({:suite_started, _opts}, state) do
    {:noreply, state}
  end

  def handle_cast({:suite_finished, _times_us}, state) do
    for test_result <- state.test_results do
      path = Path.join([state.test_directory, "#{test_result.uuid}-result.json"])
      File.write!(path, JSON.encode!(test_result))
    end

    {:noreply, state}
  end

  def handle_cast({:module_started, _test_module}, state) do
    {:noreply, state}
  end

  def handle_cast({:module_finished, _test_module}, state) do
    {:noreply, state}
  end

  def handle_cast({:test_started, test}, state) do
    id = hash(test)

    new_state = %{
      state
      | current_test_result: %Allure.TestResult{
          uuid: UUIDv7.generate(),
          name: test.name,
          full_name: test.name,
          history_id: id,
          test_case_id: id,
          start: System.monotonic_time(:millisecond),
          labels: [
            %Allure.TestResult.Label{
              name: "parentSuite",
              value: test.module
            },
            %Allure.TestResult.Label{
              name: "language",
              value: "elixir"
            },
            %Allure.TestResult.Label{
              name: "framework",
              value: "ex_unit"
            }
          ]
        }
    }

    {:noreply, new_state}
  end

  def handle_cast({:test_finished, test}, state) do
    new_state =
      update_in(state, [:test_results], fn test_results ->
        [
          %Allure.TestResult{
            state.current_test_result
            | status: test_status(test),
              stop:
                state.current_test_result.start +
                  System.convert_time_unit(test.time, :microsecond, :millisecond)
          }
          | test_results
        ]
      end)
      |> update_in([:current_test_result], fn _ -> nil end)

    {:noreply, new_state}
  end

  def handle_cast({:sigquit, _tests_or_modules}, state) do
    # The VM is shutting down with tests still running
    # tests_or_modules is a list of ExUnit.Test or ExUnit.TestModule
    {:noreply, state}
  end

  def handle_cast(:max_failures_reached, state) do
    # Test run aborted due to max failures limit
    {:noreply, state}
  end

  # Deprecated: ignore this event
  def handle_cast({:case_started, _test_module}, state) do
    {:noreply, state}
  end

  # Deprecated: ignore this event
  def handle_cast({:case_finished, _test_module}, state) do
    {:noreply, state}
  end

  defp test_status(%ExUnit.Test{state: {:failed, _}}), do: :failed

  defp hash(%ExUnit.Test{name: name, module: module}) do
    :crypto.hash(:sha256, "#{module}-#{name}") |> Base.encode64()
  end
end
