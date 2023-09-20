defmodule SCOrchestrator.ScientistOperatorPublisher do
  use Rabbit.Broker

  def start_link(opts \\ []) do
    Rabbit.Broker.start_link(__MODULE__, opts, name: __MODULE__)
  end

  # Callbacks

  @impl Rabbit.Broker
  # Perform runtime configuration per component
  def init(:connection_pool, opts), do: {:ok, opts}
  def init(:connection, opts), do: {:ok, opts}
  def init(:topology, opts), do: {:ok, opts}
  def init(:producer_pool, opts), do: {:ok, opts}
  def init(:producer, opts), do: {:ok, opts}
  def init(:consumer_supervisor, opts), do: {:ok, opts}
  def init(:consumer, opts), do: {:ok, opts}

  @impl Rabbit.Broker
  def handle_message(message) do
    IO.inspect(message, label: "Got message")
    {:ack, message}
  end

  @impl Rabbit.Broker
  def handle_error(message) do
    # Handle message errors per consumer
    {:nack, message}
  end
end
