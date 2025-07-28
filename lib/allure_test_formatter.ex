defmodule AllureTestFormatter do
  @moduledoc """
  AllureTestFormatter is an ExUnit formatter that generates Allure test results.

  It implements the ExUnit.Formatter behaviour and receives events as GenServer casts
  to generate Allure-compatible test result files.
  """

  use GenServer

  def init(opts) do
    test_results = "allure-results"
    File.rm_rf(test_results)
    File.mkdir_p!(test_results)

    # Store configuration and initialize state
    state = %{
      config: opts,
      test_results: [],
      test_directory: test_results,
      current_test_result: nil
    }

    {:ok, state}
  end

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
    {status, details} = test_status(test)

    new_state =
      update_in(state, [:test_results], fn test_results ->
        [
          %Allure.TestResult{
            state.current_test_result
            | status: status,
              status_details: details,
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

  def handle_cast(_, state), do: {:noreply, state}

  defp test_status(%ExUnit.Test{state: nil}), do: {"passed", nil}

  defp test_status(%ExUnit.Test{state: {:failed, errors}}) do
    {message, trace} =
      Enum.reduce(errors, {[], []}, fn {_, reason, stacktrace}, {message, trace} ->
        {[Exception.message(reason) | message], [Exception.format_stacktrace(stacktrace) | trace]}
      end)

    string = fn iodata ->
      Enum.intersperse(iodata, "\n\n") |> IO.iodata_to_binary() |> String.trim()
    end

    {"failed",
     %Allure.TestResult.StatusDetails{
       message: string.(message),
       trace: string.(trace)
     }}
  end

  defp test_status(%ExUnit.Test{state: {:skipped, message}}) do
    {"skipped", %Allure.TestResult.StatusDetails{message: message}}
  end

  defp test_status(%ExUnit.Test{state: {:excluded, message}}) do
    {"skipped", %Allure.TestResult.StatusDetails{message: message}}
  end

  defp test_status(%ExUnit.Test{state: {:invalid, _}}), do: {"unknown", nil}

  defp hash(%ExUnit.Test{name: name, module: module}) do
    :crypto.hash(:sha256, "#{module}-#{name}") |> Base.encode64()
  end
end
