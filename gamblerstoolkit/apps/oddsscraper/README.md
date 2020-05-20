# Mlbodds

An autonomous odd state generator pulling data from many to one sources.
The odds Oracle generates a dynamic supervisor and scrapes multiple websites 
from the lib/scrapers folder.   The results are passed onto the dynamic supervisor
which syhthesizes many results into the best possible representation of the markets
odds.

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `nbaodds` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:mlbodds, "~> 0.1.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/nbaodds](https://hexdocs.pm/nbaodds).

