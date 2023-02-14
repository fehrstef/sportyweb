defmodule Sportyweb.Asset do
  @moduledoc """
  The Asset context.
  """

  import Ecto.Query, warn: false
  alias Sportyweb.Repo

  alias Sportyweb.Asset.Venue

  @doc """
  Returns a clubs list of venues.

  ## Examples

      iex> list_venues(1)
      [%Venue{}, ...]

  """
  def list_venues(club_id) do
    query = from(v in Venue, where: v.club_id == ^club_id, order_by: v.name)
    Repo.all(query)
  end

  @doc """
  Returns a clubs list of venues. Preloads associations.

  ## Examples

      iex> list_venues(1, [:equipment])
      [%Venue{}, ...]

  """
  def list_venues(club_id, preloads) do
    Repo.preload(list_venues(club_id), preloads)
  end

  @doc """
  Gets a single venue.

  Raises `Ecto.NoResultsError` if the Venue does not exist.

  ## Examples

      iex> get_venue!(123)
      %Venue{}

      iex> get_venue!(456)
      ** (Ecto.NoResultsError)

  """
  def get_venue!(id), do: Repo.get!(Venue, id)

  @doc """
  Gets a single venue. Preloads associations.

  Raises `Ecto.NoResultsError` if the Venue does not exist.

  ## Examples

      iex> get_venue!(123, [:club])
      %Department{}

      iex> get_venue!(456, [:club])
      ** (Ecto.NoResultsError)

  """
  def get_venue!(id, preloads) do
    Venue
    |> Repo.get!(id)
    |> Repo.preload(preloads)
  end

  @doc """
  Creates a venue.

  ## Examples

      iex> create_venue(%{field: value})
      {:ok, %Venue{}}

      iex> create_venue(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_venue(attrs \\ %{}) do
    %Venue{}
    |> Venue.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a venue.

  ## Examples

      iex> update_venue(venue, %{field: new_value})
      {:ok, %Venue{}}

      iex> update_venue(venue, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_venue(%Venue{} = venue, attrs) do
    venue
    |> Venue.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a venue.

  ## Examples

      iex> delete_venue(venue)
      {:ok, %Venue{}}

      iex> delete_venue(venue)
      {:error, %Ecto.Changeset{}}

  """
  def delete_venue(%Venue{} = venue) do
    Repo.delete(venue)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking venue changes.

  ## Examples

      iex> change_venue(venue)
      %Ecto.Changeset{data: %Venue{}}

  """
  def change_venue(%Venue{} = venue, attrs \\ %{}) do
    Venue.changeset(venue, attrs)
  end
end
