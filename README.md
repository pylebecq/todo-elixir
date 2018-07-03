# todo-elixir

## Prerequisites

* Elixir 1.6
* Redis
* MySQL

## Engine

1. Go to the engine directory (`cd engine`).
2. Install dependencies with `mix deps.get`.
3. Make sure mysql and redis are correctly configured in file `config/dev.exs` for MySQL and `config/config.exs` for redis.
4. Create schema and migrate database with `mix ecto.create && mix ecto.migrate`.
5. Start phoenix server with `NODE=engine mix phx.server` and visit http://localhost:4000/.

## Workers

1. Go to the worker directory (`cd worker`).
2. Install dependencies with `mix deps.get`.
3. Make sure redis is correctly configured in file `config/config.exs`.
4. Start phoenix server with `NODE=worker1 PORT=4001 mix phx.server` and visit http://localhost:4001/.
5. You can do step 4 in another terminal if you want more workers with `NODE=worker2 PORT=4002 mix phx.server` and visit http://localhost:4002/.
