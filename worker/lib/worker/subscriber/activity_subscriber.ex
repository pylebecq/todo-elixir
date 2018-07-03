defmodule Worker.ActivitySubscriber do
  use GenServer

  def start_link(channel) do
    GenServer.start_link(__MODULE__, channel, name: __MODULE__)
  end

  def init(channel) do
    pid = self()
    ref = WorkerWeb.Endpoint.subscribe(channel)
    WorkerWeb.Endpoint.broadcast("activity:all", "sync:" <> System.get_env("NODE"), %{type: :sync_request})
    {:ok, {pid, channel, ref, %{}}}
  end

  def get_todos(server) do
    GenServer.call(server, :get_todos)
  end

  def handle_call(:get_todos, _from, {pid, channel, ref, todos} = state) do
    todoList = Enum.map(todos, fn({k, v}) -> v end)
    {:reply, todoList, state}
  end

  def handle_info(%{event: "todo:new", payload: payload} = message, {pid, channel, ref, todos}) do
    {id, todo} = Worker.Todo.from_payload(payload)
    todos = Map.put(todos, id, todo)
    state = {pid, channel, ref, todos}
    {:noreply, state}
  end

  def handle_info(%{event: "todo:update", payload: payload} = message, {pid, channel, ref, todos}) do
    {id, todo} = Worker.Todo.from_payload(payload)
    todos = Map.put(todos, id, todo)
    state = {pid, channel, ref, todos}
    {:noreply, state}
  end

  def handle_info(%{event: "todo:delete", payload: payload} = message, {pid, channel, ref, todos}) do
    todos = Map.delete(todos, String.to_atom("#{payload.id}"))
    state = {pid, channel, ref, todos}
    {:noreply, state}
  end

  def handle_info(%{event: "sync:" <> node, payload: payload}, {pid, channel, ref, todos} = state) do
    if node == System.get_env("NODE") and payload.type == :sync_response do
      todos = payload.todos |> convert_payload_todos()
        IO.inspect todos
      {:noreply, {pid, channel, ref, todos}}
    else
      {:noreply, state}
    end
  end

  def handle_info(message, state) do
    IO.inspect "#######################"
    IO.inspect "Catch All - Received Message:"
    IO.inspect message
    IO.inspect state
    IO.inspect "#######################"
    {:noreply, state}
  end

  defp convert_payload_todos(todos) do
    IO.inspect "CONVERT"
    IO.inspect todos
    newtodos = todos
      |> Enum.map(fn({_, value}) -> Worker.Todo.from_payload(value) end)
      |> Enum.into(%{})
    IO.inspect "TO"
    IO.inspect newtodos
    newtodos
  end
end
