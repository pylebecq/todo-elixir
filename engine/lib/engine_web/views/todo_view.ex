defmodule EngineWeb.TodoView do
  use EngineWeb, :view
  
  def status(%Engine.Todo{done: done}) do
    if done == true do
      "Done"
    else
      "To do"
    end
  end
end
