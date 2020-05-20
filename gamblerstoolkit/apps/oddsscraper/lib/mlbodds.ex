defmodule MlbOdds.Oracle do
  use GenServer
  require Logger
  @moduledoc """
  Documentation for Mlbodds.
  """

  def start_link(opts) do
    GenServer.start_link(__MODULE__, :ok, opts)
  end

  def stop() do
    GenServer.call(__MODULE__, :stop)
  end

  @doc """
  Gets the current state of the odds server
  arity: (0)
  """
  def get_state() do
    GenServer.call(__MODULE__, :getstate)
  end

  @doc """
  Creates a supervised Agent that holds the state of a scraped website.
  arity: (1)
      agent: A module that scrapes a website sepcified in init.
  """
  def odds_axlotl(agent) do
    GenServer.cast(__MODULE__, {:odds_axlotl, agent})
  end

  @doc """
  hot code swaps a new date into the odds agent so it updates 
  arity: (1)
      date ~D[sigil]: date sigil signifing which date to scrape
  """
  def swap_date(date) do
    GenServer.cast(__MODULE__, {:swapdate, date})
  end

  def init(:ok) do
    config = %{
      born: DateTime.utc_now(),
      last_updated: 0,
      heartbeat: 0
    }

    agents = [MlbOdds.SBRAgent]
    names = %{}
    refs = %{}
    payload = %{}

    ## start up all the scrapers
    initialize(agents)
    schedule_scrapers()
    {:ok, %{config: config, names: names, refs: refs, payload: payload, agents: agents}}
  end

  ## Handle Server Responses
  def handle_call(:getstate, _From, state) do
    {:reply, state, state}
  end

  def handle_call(:stop, _From, state) do
    {:stop, :normal, :ok, state}
  end

  def handle_cast({:swapdate, date}, state) do
    ############################
    ## Cycle through scrapers
    ############################
    Enum.each(MlbOdds.DynamicSupervisor.children(), fn scraper ->
      pid = scraper |> elem(1)  ##get process id

      Agent.update(pid, fn _state ->
        %{born: DateTime.utc_now(), last_updated: DateTime.utc_now(), payload: %{}, date: date}
      end)
    end)

    {:noreply, state}
  end

  def handle_cast({:odds_axlotl, scraper}, state) do
    if Map.has_key?(state.names, scraper) do
      {:noreply, state}
    else
      case Process.whereis(scraper) do
        nil ->
          {:ok, bin} = MlbOdds.DynamicSupervisor.add_odds_scraper(scraper)
          ref = Process.monitor(bin)
          new_refs = Map.put(state.refs, ref, scraper)
          new_names = Map.put(state.names, scraper, bin)
          ################
          # Daemonize
          ################
          scraper.fetch
          {:noreply, %{state | refs: new_refs, names: new_names}}

        _ ->
          {:noreply, state}
      end
    end
  end

  @doc """
  Handle a :DOWN message
  """
  def handle_info({:DOWN, ref, :process, _, _}, state) do
    Logger.info("DOWN")
    {name, new_refs} = Map.pop(state.refs, ref)
    new_names = Map.delete(state.names, name)
    {:noreply, %{state | refs: new_refs, names: new_names}}
  end

  @doc """
  Handle the repeating work function
  """
  def handle_info(:work, state) do
    ##zombie check
    new_state =
      Enum.map(state|>Map.get(:agents), fn agent ->
        case Map.has_key?(state.names, agent) do
          true ->
            state
          _ ->
            pid = Process.whereis(agent)
            ref = Process.monitor(pid)
            newnames = Map.put(state.names, agent, pid)
            newrefs = Map.put(state.refs, ref, agent)
            %{state | refs: newrefs, names: newnames}
        end
      end)
      |>Enum.at(0)

    ## rerun the fetches
    Enum.each(new_state.agents, fn scraper ->
      scraper.fetch
    end)

    ## Rerun the scraper.
    schedule_scrapers()

    {:noreply, new_state}
  end

  @doc """
  Set a timeout with delay for the scraper to recast its fetch function
  """
  def schedule_scrapers() do
    Process.send_after(self(), :work, 5_000)
  end

  @doc """
  Initialize the scraper array for the first time
  """
  def initialize(agents) do
    Enum.each(agents, fn agent ->
      MlbOdds.Oracle.odds_axlotl(agent)
    end)
  end
end
