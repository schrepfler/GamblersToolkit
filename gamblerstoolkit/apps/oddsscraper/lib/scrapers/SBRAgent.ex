defmodule MlbOdds.SBRAgent do
  use Agent, restart: :permanent
  use Hound.Helpers

  ##############################
  ## The Commons
  ##############################
  @doc """
  Spins up a linked scraper bin
  """
  def start_link(_) do
    Agent.start_link(
      fn ->
        %{
          born: DateTime.utc_now(),
          last_updated: DateTime.utc_now(),
          date: Timex.now() |> Timex.shift(hours: -8) |> Timex.to_date()
        }
      end,
      name: __MODULE__
    )
  end

  @doc """
  Get a key-value pair from the Scrapers state
  """
  def get(key) do
    Agent.get(__MODULE__, &Map.get(&1, key))
  end

  @doc """
  Return the global state which the agent wraps around
  """
  def get_state() do
    Agent.get(__MODULE__, fn state -> state end)
  end

  @doc """
  Put a value in the scraper state vector
  """
  def put(key, value) do
    Agent.update(__MODULE__, &Map.put(&1, key, value))
  end

  @doc """
  Crash spun up
  """
  def crash() do
    Agent.stop(__MODULE__, :shutdown)
  end

  ################################
  ## Fetch
  ################################
  def fetch() do
    ## snag the YVR date.
    datestring = __MODULE__.get(:date) |> Date.to_iso8601() |> String.replace("-", "_")

    ## Scraping address
    url =
      Enum.join([
        "https://classic.sportsbookreview.com/betting-odds/mlb-baseball/?date=",
        datestring |> String.replace("_", "")
      ])

    ################################
    # HEADLESS BROWSER
    ################################

    Hound.start_session()
    navigate_to(url)
    :timer.sleep(5000)
    body = page_source()
    Hound.end_session()
    
    ## Get the matchups and odds.
    teamlist =
      body
      |> Floki.find("span[class=team-name] a")
      |> Enum.map(fn a -> a |> Floki.text() |> String.slice(0..2) end)
      |> Enum.map(fn a -> a |> String.trim() |> String.downcase() |> roto_to_sbr end)

    oddslist =
      body
      |> Floki.find("div[id*=\"-238-\"]")
      |> Enum.map(fn a -> a |> Floki.text() end)
      |> Enum.map(fn a -> blankodd(a) |> String.to_integer() |> convert_to_dec end)

    numgames = ((teamlist |> Enum.count()) / 2) |> Kernel.trunc()

    ## Collect all of the odds from SBR Forum.
    allodds =
      cond do
        numgames > 0 ->
          Enum.reduce(0..(numgames - 1), %{}, fn indice, acc ->
            teama = teamlist |> Enum.at(2 * indice) |> String.downcase()
            teamb = teamlist |> Enum.at(2 * indice + 1) |> String.downcase()
            oddsa = oddslist |> Enum.at(2 * indice)
            oddsb = oddslist |> Enum.at(2 * indice + 1)

            gamenum =
              Enum.reduce(teamlist, 0, fn t, tacc ->
                cond do
                  t |> String.downcase() == teama -> tacc + 1
                  true -> tacc
                end
              end)

            gid =
              Enum.join([
                datestring |> String.replace("_", "/"),
                "/",
                teama,
                "mlb-",
                teamb,
                "mlb-",
                gamenum |> Integer.to_string()
              ])

            Map.put(acc, gid, %{
              gid: gid,
              awayml: oddsa,
              homeml: oddsb,
              awayteam: teama,
              hometeam: teamb
            })
          end)

        true ->
          []
      end

    __MODULE__.put(:payload, allodds)
    __MODULE__.put(:last_updated, DateTime.utc_now())
  end

  defp blankodd(oddstring) do
    cond do
      oddstring == "" ->
        "+200"

      true ->
        oddstring
    end
  end

  defp roto_to_sbr(abbr) do
    case abbr |> String.downcase() do
      "kc" -> "kca"
      "wsh" -> "was"
      "sd" -> "sdn"
      "stl" -> "sln"
      "sf" -> "sfn"
      "laa" -> "ana"
      "nym" -> "nyn"
      "chc" -> "chn"
      "cws" -> "cha"
      "lad" -> "lan"
      "tb" -> "tba"
      "nyy" -> "nya"
      a -> a
    end
  end

  defp convert_to_dec(odds) do
    cond do
      odds == :error ->
        2.0

      odds > 0 ->
        odds / 100.0 + 1.0

      odds < 0 ->
        -(100.0 / odds) + 1.0
    end
  end
end
