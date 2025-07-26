defmodule AllureTestFormatter.MixProject do
  use Mix.Project

  def project do
    [
      app: :allure_test_formatter,
      version: "0.1.0",
      elixir: "~> 1.18",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:uuidv7, "~> 1.0"},
      {:igniter, "~> 0.6", only: [:dev, :test]}
    ]
  end
end
