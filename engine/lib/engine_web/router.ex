defmodule EngineWeb.Router do
  use EngineWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", EngineWeb do
    pipe_through :browser # Use the default browser stack

    get "/", TodoController, :index
    get "/add", TodoController, :new
    post "/create", TodoController, :create
    get "/:id/edit", TodoController, :edit
    put "/:id/update", TodoController, :update
    delete "/:id", TodoController, :delete
  end

  # Other scopes may use custom stacks.
  # scope "/api", EngineWeb do
  #   pipe_through :api
  # end
end
