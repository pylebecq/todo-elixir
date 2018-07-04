defmodule Worker.Amqp do
  use GenServer

  ## Client API

  def start_link do
    GenServer.start_link(__MODULE__, :ok, name: :amqp_publisher)
  end

  def publish(message) do
    {:ok, encoded_message} = Poison.encode(message)
    GenServer.cast(:amqp_publisher, {:publish, encoded_message})
  end

  ## Server Callbacks

  def init(:ok) do
    {:ok, connection} = AMQP.Connection.open
    {:ok, channel} = AMQP.Channel.open(connection)
    :ok = AMQP.Exchange.fanout(channel, "todo_activity", durable: true)
    {:ok, %{channel: channel, connection: connection} }
  end

  def handle_cast({:publish, message}, state) do
    AMQP.Basic.publish(state.channel, "todo_activity", "", message)
    {:noreply, state}
  end

  def terminate(_reason, state) do
    AMQP.Connection.close(state.connection)
  end
end
