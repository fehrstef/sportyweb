defmodule Sportyweb.Cooperation do
  @moduledoc """
  The Cooperation context.
  """

  import Ecto.Query, warn: false
  alias Sportyweb.Repo

  alias Sportyweb.Cooperation.Request

  @doc """
  Returns the list of requests.

  ## Examples

      iex> list_requests()
      [%Request{}, ...]

  """
  def list_requests do
    Repo.all(Request)
  end

  def list_requests(club_id, order_by, filters) do
    query = from(c in Request, where: c.club_id == ^club_id)

    query =
      if order_by == nil do
        order_by(query, asc: :opening_date)
      else
        order_by(query, ^order_by)
      end

    query =
      if filters == nil || Enum.empty?(filters) do
        query
      else
        where(query, ^filter_request_like(filters))
      end

    Repo.all(query)
  end

  def list_requests(club_id, order_by, filters, preloads) do
    club_id
    |> list_requests(order_by, filters)
    |> Repo.preload(preloads)
  end

  defp filter_request_like(filters) do
    Enum.reduce(filters, dynamic(true), fn
      {:author_name, value}, dynamic ->
        dynamic([c], ^dynamic and ilike(c.author_name, ^prepare_for_like(value)))

      {:author_mail, value}, dynamic ->
        dynamic([c], ^dynamic and ilike(c.author_mail, ^prepare_for_like(value)))

      {:type, value}, dynamic ->
        dynamic([c], ^dynamic and ilike(c.type, ^prepare_for_like(value)))

      {:note, value}, dynamic ->
        dynamic([c], ^dynamic and ilike(c.note, ^prepare_for_like(value)))

      {:is_author_confirmed, value}, dynamic ->
        dynamic([c], ^dynamic and ilike(c.is_author_confirmed, ^prepare_for_like(value)))

      {:state, value}, dynamic ->
        dynamic([c], ^dynamic and ilike(c.state, ^prepare_for_like(value)))

      {:confirmation_token, value}, dynamic ->
        dynamic([c], ^dynamic and ilike(c.confirmation_token, ^prepare_for_like(value)))
    end)
  end

  defp prepare_for_like(value) do
    "%#{value}%"
  end

  @doc """
  Gets a single request.

  Raises `Ecto.NoResultsError` if the Request does not exist.

  ## Examples

      iex> get_request!(123)
      %Request{}

      iex> get_request!(456)
      ** (Ecto.NoResultsError)

  """
  def get_request!(id), do: Repo.get!(Request, id)

  def get_request!(id, preloads) do
    Request
    |> Repo.get!(id)
    |> Repo.preload(preloads)
  end

  @doc """
  Creates a request.

  ## Examples

      iex> create_request(%{field: value})
      {:ok, %Request{}}

      iex> create_request(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_request(attrs \\ %{}) do
    %Request{}
    |> Request.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a request.

  ## Examples

      iex> update_request(request, %{field: new_value})
      {:ok, %Request{}}

      iex> update_request(request, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_request(%Request{} = request, attrs) do
    request
    |> Request.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a request.

  ## Examples

      iex> delete_request(request)
      {:ok, %Request{}}

      iex> delete_request(request)
      {:error, %Ecto.Changeset{}}

  """
  def delete_request(%Request{} = request) do
    Repo.delete(request)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking request changes.

  ## Examples

      iex> change_request(request)
      %Ecto.Changeset{data: %Request{}}

  """
  def change_request(%Request{} = request, attrs \\ %{}) do
    Request.changeset(request, attrs)
  end
end
