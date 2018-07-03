defmodule WorkerWeb.PageView do
  use WorkerWeb, :view

  def status(%Worker.Todo{done: done}) do
    if done == true do
      "Done"
    else
      "To do"
    end
  end
end
