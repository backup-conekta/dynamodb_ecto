defmodule Dynamo.Ecto.Connection do
  @moduledoc false

  alias Dynamo.Ecto.NormalizedQuery.ReadQuery
  alias Dynamo.Ecto.NormalizedQuery.WriteQuery
  alias Dynamo.Ecto.NormalizedQuery.CommandQuery
  alias Dynamo.Ecto.NormalizedQuery.CountQuery
  alias Dynamo.Ecto.NormalizedQuery.AggregateQuery

  ## Worker

  def storage_down(opts) do
    opts = Keyword.put(opts, :size, 1)

    {:ok, _} = Dynamo.Ecto.AdminPool.start_link(opts)

    try do
      Dynamo.run_command(Dynamo.Ecto.AdminPool, dropDatabase: 1)
      :ok
    after
      true = Dynamo.Ecto.AdminPool.stop
    end
  end

  ## Callbacks for adapter

  def read(conn, query, opts \\ [])

  def read(conn, %ReadQuery{} = query, opts) do
    opts  = [projection: query.projection, sort: query.order] ++ query.opts ++ opts
    coll  = query.coll
    query = query.query

    Dynamo.find(conn, coll, query, opts)
  end

  def read(conn, %CountQuery{} = query, opts) do
    coll  = query.coll
    opts  = query.opts ++ opts
    query = query.query

    [%{"value" => Dynamo.count(conn, coll, query, opts)}]
  end

  def read(conn, %AggregateQuery{} = query, opts) do
    coll     = query.coll
    opts     = query.opts ++ opts
    pipeline = query.pipeline

    Dynamo.aggregate(conn, coll, pipeline, opts)
  end

  def delete_all(conn, %WriteQuery{} = query, opts) do
    coll     = query.coll
    opts     = query.opts ++ opts
    query    = query.query

    case Dynamo.delete_many(conn, coll, query, opts) do
      {:ok, %{deleted_count: n}} -> n
    end
  end

  def delete(conn, %WriteQuery{} = query, opts) do
    coll     = query.coll
    opts     = query.opts ++ opts
    query    = query.query

    catch_constraint_errors fn ->
      case Dynamo.delete_one(conn, coll, query, opts) do
        {:ok, %{deleted_count: 1}} ->
          {:ok, []}
        {:ok, _} ->
          {:error, :stale}
      end
    end
  end

  def update_all(conn, %WriteQuery{} = query, opts) do
    coll     = query.coll
    command  = query.command
    opts     = query.opts ++ opts
    query    = query.query

    case Dynamo.update_many(conn, coll, query, command, opts) do
      {:ok, %{modified_count: n}} -> n
    end
  end

  def update(conn, %WriteQuery{} = query, opts) do
    coll     = query.coll
    command  = query.command
    opts     = query.opts ++ opts
    query    = query.query

    catch_constraint_errors fn ->
      case Dynamo.update_one(conn, coll, query, command, opts) do
        {:ok, %{modified_count: 1}} ->
          {:ok, []}
        {:ok, _} ->
          {:error, :stale}
      end
    end
  end

  def insert(conn, %WriteQuery{} = query, opts) do
    coll     = query.coll
    command  = query.command
    opts     = query.opts ++ opts

    catch_constraint_errors fn ->
      Dynamo.insert_one(conn, coll, command, opts)
    end
  end

  def command(conn, %CommandQuery{} = query, opts) do
    command  = query.command
    opts     = query.opts ++ opts

    Dynamo.run_command(conn, command, opts)
  end

  defp catch_constraint_errors(fun) do
    try do
      fun.()
    rescue
      e in Dynamo.Error ->
        stacktrace = System.stacktrace
        case e do
          %Dynamo.Error{code: 11000, message: msg} ->
            {:invalid, [unique: extract_index(msg)]}
          other ->
            reraise other, stacktrace
        end
    end
  end

  def constraint(msg) do
    [unique: extract_index(msg)]
  end

  defp extract_index(msg) do
    parts = String.split(msg, [".$", "index: ", " dup "])

    case Enum.reverse(parts) do
      [_, index | _] ->
        String.strip(index)
      _  ->
        raise "failed to extract index from error message: #{inspect msg}"
    end
  end
end
