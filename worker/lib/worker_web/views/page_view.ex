defmodule WorkerWeb.PageView do
  use WorkerWeb, :view

  def status(%{"done" => done}) do
    if done == true do
      "Done"
    else
      "To do"
    end
  end
end
