defmodule Allure.TestResult.Link do
  @moduledoc """
  Represents a link attached to a test or step.
  """

  @type t :: %__MODULE__{
          name: String.t(),
          url: String.t(),
          type: String.t()
        }

  @enforce_keys [:name, :url, :type]
  defstruct [:name, :url, :type]
end

defimpl JSON.Encoder, for: Allure.TestResult.Link do
  def encode(value, _opts) do
    %{
      "name" => value.name,
      "url" => value.url,
      "type" => value.type
    }
  end
end

defmodule Allure.TestResult.Label do
  @moduledoc """
  Represents a label attached to a test or step.
  Labels can include metadata like tags, severity, owner, epic, feature, story, etc.
  """

  @type t :: %__MODULE__{
          name: String.t(),
          value: String.t()
        }

  @enforce_keys [:name, :value]
  defstruct [:name, :value]
end

defimpl JSON.Encoder, for: Allure.TestResult.Label do
  def encode(value, encoder) do
    %{
      "name" => value.name,
      "value" => value.value
    }
    |> encoder.(encoder)
  end
end

defmodule Allure.TestResult.Parameter do
  @moduledoc """
  Represents a parameter attached to a test or step.
  """

  @type t :: %__MODULE__{
          name: String.t(),
          value: String.t(),
          excluded: boolean() | nil,
          mode: String.t() | nil
        }

  @enforce_keys [:name, :value]
  defstruct [:name, :value, :excluded, :mode]
end

defimpl JSON.Encoder, for: Allure.TestResult.Parameter do
  def encode(value, _opts) do
    %{
      "name" => value.name,
      "value" => value.value,
      "excluded" => value.excluded,
      "mode" => value.mode
    }
    |> Enum.reject(fn {_k, v} -> is_nil(v) end)
    |> Map.new()
  end
end

defmodule Allure.TestResult.Attachment do
  @moduledoc """
  Represents an attachment added to a test or step.
  The content is stored as a separate file in the results directory.
  """

  @type t :: %__MODULE__{
          name: String.t(),
          source: String.t(),
          type: String.t()
        }

  @enforce_keys [:name, :source, :type]
  defstruct [:name, :source, :type]
end

defimpl JSON.Encoder, for: Allure.TestResult.Attachment do
  def encode(value, _opts) do
    %{
      "name" => value.name,
      "source" => value.source,
      "type" => value.type
    }
  end
end

defmodule Allure.TestResult.StatusDetails do
  @moduledoc """
  Represents detailed information about the test or step status.
  """

  @type t :: %__MODULE__{
          known: boolean() | nil,
          muted: boolean() | nil,
          flaky: boolean() | nil,
          message: String.t() | nil,
          trace: String.t() | nil
        }

  defstruct [:known, :muted, :flaky, :message, :trace]
end

defimpl JSON.Encoder, for: Allure.TestResult.StatusDetails do
  def encode(value, _opts) do
    %{
      "known" => value.known,
      "muted" => value.muted,
      "flaky" => value.flaky,
      "message" => value.message,
      "trace" => value.trace
    }
    |> Enum.reject(fn {_k, v} -> is_nil(v) end)
    |> Map.new()
  end
end

defmodule Allure.TestResult.Step do
  @moduledoc """
  Represents a test step or sub-step.
  Steps can be nested and contain the same metadata as test results.
  """

  @type t :: %__MODULE__{
          name: String.t(),
          status: String.t(),
          status_details: Allure.TestResult.StatusDetails.t() | nil,
          stage: String.t() | nil,
          description: String.t() | nil,
          description_html: String.t() | nil,
          start: integer() | nil,
          stop: integer() | nil,
          links: [Allure.TestResult.Link.t()] | nil,
          labels: [Allure.TestResult.Label.t()] | nil,
          parameters: [Allure.TestResult.Parameter.t()] | nil,
          attachments: [Allure.TestResult.Attachment.t()] | nil,
          steps: [Allure.TestResult.Step.t()] | nil
        }

  @enforce_keys [:name, :status]
  defstruct [
    :name,
    :status,
    :status_details,
    :stage,
    :description,
    :description_html,
    :start,
    :stop,
    :links,
    :labels,
    :parameters,
    :attachments,
    :steps
  ]
end

defimpl JSON.Encoder, for: Allure.TestResult.Step do
  def encode(value, encoder) do
    %{
      "name" => value.name,
      "status" => value.status,
      "statusDetails" => value.status_details,
      "stage" => value.stage,
      "description" => value.description,
      "descriptionHtml" => value.description_html,
      "start" => value.start,
      "stop" => value.stop,
      "links" => value.links,
      "labels" => value.labels,
      "parameters" => value.parameters,
      "attachments" => value.attachments,
      "steps" => value.steps
    }
    |> Enum.reject(fn {_k, v} -> is_nil(v) end)
    |> Map.new()
    |> encoder.(encoder)
  end
end

defmodule Allure.TestResult do
  @moduledoc """
  Represents a complete Allure test result.
  This is the root structure stored in {uuid}-result.json files.
  """

  @type t :: %__MODULE__{
          uuid: String.t(),
          history_id: String.t() | nil,
          test_case_id: String.t() | nil,
          name: String.t(),
          full_name: String.t() | nil,
          description: String.t() | nil,
          description_html: String.t() | nil,
          status: String.t(),
          status_details: Allure.TestResult.StatusDetails.t() | nil,
          stage: String.t() | nil,
          start: integer() | nil,
          stop: integer() | nil,
          links: [Allure.TestResult.Link.t()] | nil,
          labels: [Allure.TestResult.Label.t()] | nil,
          parameters: [Allure.TestResult.Parameter.t()] | nil,
          attachments: [Allure.TestResult.Attachment.t()] | nil,
          steps: [Allure.TestResult.Step.t()] | nil
        }

  @enforce_keys [:uuid, :name]
  defstruct [
    :uuid,
    :history_id,
    :test_case_id,
    :name,
    :full_name,
    :description,
    :description_html,
    :status,
    :status_details,
    :stage,
    :start,
    :stop,
    :links,
    :labels,
    :parameters,
    :attachments,
    steps: []
  ]
end

defimpl JSON.Encoder, for: Allure.TestResult do
  def encode(value, encoder) do
    %{
      "uuid" => value.uuid,
      "historyId" => value.history_id,
      "testCaseId" => value.test_case_id,
      "name" => value.name,
      "fullName" => value.full_name,
      "description" => value.description,
      "descriptionHtml" => value.description_html,
      "status" => value.status,
      "statusDetails" => value.status_details,
      "stage" => value.stage,
      "start" => value.start,
      "stop" => value.stop,
      "links" => value.links,
      "labels" => value.labels,
      "parameters" => value.parameters,
      "attachments" => value.attachments,
      "steps" => value.steps
    }
    |> Enum.reject(fn {_k, v} -> is_nil(v) end)
    |> Map.new()
    |> encoder.(encoder)
  end
end
