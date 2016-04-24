defmodule Dynamo.Ecto.ObjectID do
  @moduledoc """
  An Ecto type to represent DynamoDB's ObjectIDs

  Represented as hex-encoded binaries of 24 characters.
  """

  @behaviour Ecto.Type

  @doc """
  The Ecto primitive type.
  """
  def type, do: :binary_id


  @doc """
  Converts to a format acceptable for the database
  """
  def dump(binary) do
    {:ok, %{value: binary}}
  end

  @doc """
  Converts from the format returned from the database
  """
  def load(binary) do
    try do
      {:ok, binary }
    catch
      :throw, :error ->
        :error
    end
  end

  @doc """
  Generates a new ObjectID
  """
  def generate do
    %BSON.ObjectId{value: value} = Dynamo.IdServer.new
    encode(value)
  end

  def encode(<< l0::4, h0::4, l1::4, h1::4,  l2::4,  h2::4,  l3::4,  h3::4,
                l4::4, h4::4, l5::4, h5::4,  l6::4,  h6::4,  l7::4,  h7::4,
                l8::4, h8::4, l9::4, h9::4, l10::4, h10::4, l11::4, h11::4 >>) do
    << e(l0), e(h0), e(l1), e(h1), e(l2),  e(h2),  e(l3),  e(h3),
       e(l4), e(h4), e(l5), e(h5), e(l6),  e(h6),  e(l7),  e(h7),
       e(l8), e(h8), e(l9), e(h9), e(l10), e(h10), e(l11), e(h11) >>
  end

end
