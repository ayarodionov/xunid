defmodule Xunid.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc """
  Docummentation for Xunid.Application
  """

  use Application
  require Logger

  @doc """
    Starts Unid module
  """
  def start(_type, _args) do
    nodeId = Application.get_env(:xunid, :nodeId)
    Logger.info("Start nodeId: #{nodeId}")

    children = [
      %{
        id: Unid,
        start: {Unid, :start_link, [nodeId]}
      }
    ]

    opts = [strategy: :one_for_one, name: Xunid.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
