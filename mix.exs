defmodule AllureTestFormatter.MixProject do
  use Mix.Project

  def project do
    [
      app: :allure_test_formatter,
      version: "0.1.0",
      elixir: "~> 1.18",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      description: description(),
      package: package(),
      name: "Allure Test Formatter",
      source_url: source_url()
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
      {:ex_doc, ">= 0.0.0", only: :dev, runtime: false}
    ]
  end

  defp description do
    "Allure test report for ExUnit"
  end

  defp source_url do
    "https://github.com/wingyplus/allure_test_formatter"
  end

  defp package() do
    [
      licenses: ["Apache-2.0"],
      links: %{"GitHub" => source_url()}
    ]
  end
end
