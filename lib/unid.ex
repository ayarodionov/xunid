defmodule Unid do
  @moduledoc """
  Docummentation for unid
  """
  use GenServer
  use Bitwise

  @start_delay 1000
  @max_22 8_388_607
  @max_32 4_294_967_295
  @cntr_length 22
  @time_length 32

  @enforce_keys [:node_id, :base]
  defstruct [:node_id, :base, cntr: 0]

  def start_link(nodeId) do
    GenServer.start_link(__MODULE__, nodeId, name: __MODULE__)
  end

  @doc """
    Returns node id
  """
  def node_id() do
    GenServer.call(__MODULE__, :node_id)
  end

  @doc """
    Returns unique id
  """
  def get_id() do
    GenServer.call(__MODULE__, :get_id)
  end

  @doc """
    Returns information about current state
  """
  def info() do
    GenServer.call(__MODULE__, :info)
  end

  @doc """
    Returns time stamp since the epoch in milliseconds
  """
  def timestamp(), do: :erlang.system_time(:milli_seconds)

  ## Callbacks

  @impl true
  def init(nodeId) do
    :timer.sleep(@start_delay)

    {:ok,
     %Unid{
       node_id: nodeId,
       base: mk_base(nodeId, :erlang.system_time(:seconds))
     }}
  end

  @impl true
  def handle_call(:get_id, _from, state) when state.cntr < @max_22 do
    {:reply, state.base ||| state.cntr, %{state | cntr: state.cntr + 1}}
  end

  def handle_call(:get_id, _from, state) do
    base = mk_base(state.node_id, :erlang.system_time(:seconds))
    {:reply, base, %{state | base: Base, cntr: 1}}
  end

  def handle_call(:node_id, _from, state) do
    {:reply, state.node_id, state}
  end

  def handle_call(:info, _from, state) do
    {:reply, state, state}
  end

  @compile {:inline, mk_base: 2}
  defp mk_base(nodeId, seconds) do
    (nodeId <<< @time_length ||| (seconds &&& @max_32)) <<< @cntr_length
  end
end
