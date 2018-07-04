defmodule Engine.ActivitySubscriber do
  use GenServer

  ## Client API

  def start_link do
    GenServer.start_link(__MODULE__, :ok, name: :activity_sub)
  end

  ## Server Callbacks

  def init(:ok) do
    {:ok, connection} = AMQP.Connection.open
    {:ok, channel} = AMQP.Channel.open(connection)
    exchange_name = "todo_activity"
    :ok = AMQP.Exchange.fanout(channel, exchange_name, autodelete: true, durable: true)
    queue_name = "activity_" <> System.get_env("NODE")
    {:ok, _} = AMQP.Queue.declare(channel, queue_name, durable: true, autodelete: true)
    :ok = AMQP.Queue.bind(channel, queue_name, exchange_name)
    {:ok, %{channel: channel, connection: connection, todos: %{}}}
    :ok = AMQP.Basic.qos(channel, prefetch_count: 10)
    {:ok, _consumer_tag} = AMQP.Basic.consume(channel, queue_name)
    {:ok, channel}
  end

  # Confirmation sent by the broker after registering this process as a consumer
  def handle_info({:basic_consume_ok, %{consumer_tag: consumer_tag}}, chan) do
    {:noreply, chan}
  end

  # Sent by the broker when the consumer is unexpectedly cancelled (such as after a queue deletion)
  def handle_info({:basic_cancel, %{consumer_tag: consumer_tag}}, chan) do
    {:stop, :normal, chan}
  end

  # Confirmation sent by the broker to the consumer process after a Basic.cancel
  def handle_info({:basic_cancel_ok, %{consumer_tag: consumer_tag}}, chan) do
    {:noreply, chan}
  end

  def handle_info({:basic_deliver, payload, %{delivery_tag: tag, redelivered: redelivered}}, chan) do
    {:ok, payload} = Poison.decode(payload)
    spawn fn -> consume(chan, tag, redelivered, payload) end
    {:noreply, chan}
  end

  defp consume(channel, tag, redelivered, %{"type" => "sync_request", "node" => node}) do
    todos = Enum.map(Engine.Todo.get_todos(), fn ({k, v}) -> {"#{k}", %{"id" => v.id, "title" => v.title, "done" => v.done}} end)
      |> Enum.into(%{})
    Engine.Amqp.publish(%{"type" => "sync_response", "node" => node, "todos" => todos})
    :ok = AMQP.Basic.ack(channel, tag)
  end

  defp consume(channel, tag, redelivered, payload) do
    IO.inspect "**************** CATCH ALL **********************"
    IO.inspect payload
    :ok = AMQP.Basic.ack(channel, tag)
  end

  def handle_cast({:publish, message}, state) do
    AMQP.Basic.publish(state.channel, "todo_activity", "", message)
    {:noreply, state}
  end

  def terminate(_reason, state) do
    AMQP.Connection.close(state.connection)
  end
end
