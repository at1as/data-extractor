defmodule DataExtractor.Mixfile do
  use Mix.Project

  def project do
    [app: :dataExtractor,
     version: "0.1.0",
     elixir: "~> 1.4",
     escript: [main_module: DataExtractor],
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps()]
  end

  # Configuration for the OTP application
  def application do
    [extra_applications: [:logger]]
  end

  defp deps do
    [{:distillery, "~> 1.0"}] # Build binaries
  end
end

