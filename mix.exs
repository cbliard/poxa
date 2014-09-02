defmodule Poxa.Mixfile do
  use Mix.Project

  def project do
    [ app: :poxa,
      version: "0.3.0",
      name: "Poxa",
      elixir: "~> 0.15.0",
      deps: deps ]
  end

  def application do
    [ applications: [ :logger,
                      :crypto,
                      :gproc,
                      :cowboy ],
      included_applications: [ :jsex, :uuid, :signaturex ],
      mod: { Poxa, [] } ]
  end

  defp deps do
    [ {:cowboy, "~> 1.0.0" },
      {:jsex, "~> 2.0"},
      {:signaturex, "~> 0.0.7"},
      {:gproc, "~> 0.3.0"},
      {:uuid, github: "avtobiff/erlang-uuid", tag: "v0.4.5" },
      {:meck, "~> 0.8.2", only: :test},
      {:pusher_client, github: "edgurgel/pusher_client", only: :test},
      {:pusher, github: "edgurgel/pusher", only: :test},
      {:exrm, "0.12.11", only: :prod} ]
  end
end
