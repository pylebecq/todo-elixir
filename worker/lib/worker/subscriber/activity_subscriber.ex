defmodule Worker.ActivitySubscriber do
  use GenServer
  use AMQP

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
    Worker.Amqp.publish(%{
      "type" => "sync_request",
      "node" => System.get_env("NODE"),
    })
    {:ok, channel}
  end

  def get_todos(server) do
    GenServer.call(server, :get_todos)
  end

  def handle_call(:get_todos, _from, {_, todos} = state) do
    todoList = Enum.map(todos, fn({k, v}) -> v end)
    {:reply, todoList, state}
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
    spawn fn -> consume(chan, tag, redelivered, payload) end
    {:noreply, chan}
  end

  defp setup_queue(chan) do
    {:ok, _} = Queue.declare(chan, @queue_error, durable: true)
    # Messages that cannot be delivered to any consumer in the main queue will be routed to the error queue
    {:ok, _} = Queue.declare(chan, @queue,
                             durable: true,
                             arguments: [
                               {"x-dead-letter-exchange", :longstr, ""},
                               {"x-dead-letter-routing-key", :longstr, @queue_error}
                             ]
                            )
    :ok = Exchange.fanout(chan, @exchange, durable: true)
    :ok = Queue.bind(chan, @queue, @exchange)
  end

  defp consume(channel, tag, redelivered, payload) do
    {:ok, payload} = Poison.decode(payload)
    consume_payload(payload)
    :ok = Basic.ack channel, tag
    
  rescue
    # Requeue unless it's a redelivered message.
    # This means we will retry consuming a message once in case of exception
    # before we give up and have it moved to the error queue
    #
    # You might also want to catch :exit signal in production code.
    # Make sure you call ack, nack or reject otherwise comsumer will stop
    # receiving messages.
    exception ->
      :ok = Basic.reject channel, tag, requeue: not redelivered
      IO.puts "Error converting #{payload} to integer"
  end

  def consume_payload(%{"type" => "todo_put", "todo" => todo}) do
    Worker.TodoStorage.put(todo)
  end

  def consume_payload(%{"type" => "todo_delete", "todo" => %{"id" => id}}) do
    Worker.TodoStorage.remove(id)
  end

  def consume_payload(%{"type" => "sync_response", "node" => node, "todos" => todos}) do
    if node == System.get_env("NODE") do
      Worker.TodoStorage.sync(todos)
    end
  end

  def consume_payload(payload) do
    IO.inspect "******************* CATCH ALL *********************"
    IO.inspect payload
  end

end
