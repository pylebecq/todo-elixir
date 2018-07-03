defmodule Worker.Todo do
  defstruct [:id, :title, :done]

  def from_payload(%{id: id, title: title, done: done}) do
    {String.to_atom("#{id}"), %Worker.Todo{id: id, title: title, done: done}}
  end
end
