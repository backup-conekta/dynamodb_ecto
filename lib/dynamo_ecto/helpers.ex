defmodule Dynamo.Ecto.Helpers do
  @moduledoc """
  Defines helpers to ease working with DynamoDB in models or other places
  where you work with them. You'd probably want to import it.
  """

  @doc """
  Allows updating only a fragment of a nested document

  ## Usage in queries

      MyRepo.update_all(Post,
        set: [meta: change_map("author.name", "NewName")])
  """
  @spec change_map(String.t, term) :: Dynamo.Ecto.ChangeMap.t
  def change_map(field, value) do
    %Dynamo.Ecto.ChangeMap{field: field, value: value}
  end

  @doc """
  Allows updating only a fragment of a nested document inside an array

  ## Usage in queries

      MyRepo.update_all(Post,
        set: [comments: change_array(0, "author", "NewName")])
  """
  @spec change_array(pos_integer, String.t, term) :: Dynamo.Ecto.ChangeArray.t
  def change_array(idx, field \\ "", value) when is_integer(idx) do
    %Dynamo.Ecto.ChangeArray{field: "#{idx}.#{field}", value: value}
  end
end
