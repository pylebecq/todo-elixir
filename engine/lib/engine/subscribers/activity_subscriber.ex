defmodule Engine.ActivitySubscriber do
  use GenServer

  def start_link(channel) do
    GenServer.start_link(__MODULE__, channel)
  end

  def init(channel) do
    pid = self()
    ref = EngineWeb.Endpoint.subscribe(channel)
    {:ok, {pid, channel, ref, %{}}}
  end

  def handle_info(%{event: "sync:" <> node, payload: %{type: :sync_request}} = message, {pid, channel, ref, _} = state) do
    todos = Engine.Todo.get_todos()
    EngineWeb.Endpoint.broadcast("activity:all", "sync:" <> node, %{
      type: :sync_response,
      todos: todos
    })
    {:noreply, state}
  end

  def handle_info(message, state) do
    IO.inspect "#######################"
    IO.inspect "Catch All - Received Message:"
    IO.inspect message
    IO.inspect state
    IO.inspect "#######################"
    {:noreply, state}
  end
end
