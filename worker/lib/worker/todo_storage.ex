defmodule Worker.TodoStorage do
  use Agent

  def start_link() do
    Agent.start_link(fn -> Map.new end, name: __MODULE__)
  end

  def sync(todos) do
    Agent.update(__MODULE__, fn (_) -> todos end)
  end

  def put(todo) do
    Agent.update(__MODULE__, &Map.put(&1, todo["id"], todo))
  end

  def remove(id) do
    Agent.update(__MODULE__, &Map.drop(&1, [id]))
  end

  def get_all() do
    Agent.get(__MODULE__, fn (map) -> map end)
  end

end
