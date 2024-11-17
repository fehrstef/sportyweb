defmodule Sportyweb.Membership do
  @moduledoc """
  The Membership context.
  """

  import Ecto.Query, warn: false
  alias Sportyweb.Repo

  alias Sportyweb.Legal.Contract
  alias Sportyweb.Membership.Member

  @doc """
  Returns the list of members.

  ## Examples

      iex> list_members(1)
      [%Member{}, ...]

  """
  def list_members(club_id) do
    query = from(m in Member, where: m.club_id == ^club_id, order_by: m.last_name)
    Repo.all(query)
  end

  @doc """
  Returns a clubs list of members. Preloads associations.

  ## Examples

      iex> list_members(1, [:club])
      [%Member{}, ...]

  """
  def list_members(club_id, preloads) do
    Repo.preload(list_members(club_id), preloads)
  end

  def list_members_by_query( %{:club_id => club_id} = query) do
    mapped_query = from(m in Member, where: m.club_id == ^club_id)

    filter = query[:filter]
    mapped_query = if filter == nil do
        mapped_query
      else
        mapped_query
        |> where(^[first_name: "Uli"])
    end

    order_by = query[:order_by]
    mapped_query = if order_by == nil  do
        mapped_query
        |> order_by(:last_name)
      else
        mapped_query
        |> order_by(^order_by)
      end

      matches =  Repo.all(mapped_query)

      preloads = query[:preloads]
      if preloads == nil  do
        matches
      else
        IO.puts("load preloads")
        matches
        |> Repo.preload(preloads)
      end
  end

  @doc """
  Returns a list of members that are possible options for the given contract.
  The list won't include members that have an active (non-archived) contract
  with the given contract_object.

  Example: If the contract_object is a certain club, all members which have
  active membership contracts with this club won't be part of the returned
  options list.

  ## Examples

      iex> list_contract_member_options(1, 2)
      [%Member{}, ...]

  """
  def list_contract_member_options(contract, contract_object) do
    # Get all the ids of members that have an active contract with the contract_object.
    # These members won't appear in the select input as an option for the new contract.
    exclude_member_ids =
      Enum.map(contract_object.contracts, fn contract ->
        if !Contract.is_archived?(contract, Date.utc_today()) do
          contract.member_id
        end
      end)

    query =
      from(
        m in Member,
        where: m.club_id == ^contract.club_id,
        where: m.id not in ^exclude_member_ids,
        order_by: m.last_name
      )

    Repo.all(query)
  end

  @doc """
  Gets a single member.

  Raises `Ecto.NoResultsError` if the Member does not exist.

  ## Examples

      iex> get_member!(123)
      %Member{}

      iex> get_member!(456)
      ** (Ecto.NoResultsError)

  """
  def get_member!(id), do: Repo.get!(Member, id)

  @doc """
  Gets a single member. Preloads associations.

  Raises `Ecto.NoResultsError` if the Member does not exist.

  ## Examples

      iex> get_member!(123, [:club])
      %Member{}

      iex> get_member!(456, [:club])
      ** (Ecto.NoResultsError)

  """
  def get_member!(id, preloads) do
    Member
    |> Repo.get!(id)
    |> Repo.preload(preloads)
  end

  @doc """
  Creates a member.

  ## Examples

      iex> create_member(%{field: value})
      {:ok, %Member{}}

      iex> create_member(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_member(attrs \\ %{}) do
    %Member{}
    |> Member.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a member.

  ## Examples

      iex> update_member(member, %{field: new_value})
      {:ok, %Member{}}

      iex> update_member(member, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_member(%Member{} = member, attrs) do
    member
    |> Member.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a member.

  ## Examples

      iex> delete_member(member)
      {:ok, %Member{}}

      iex> delete_member(member)
      {:error, %Ecto.Changeset{}}

  """
  def delete_member(%Member{} = member) do
    Repo.delete(member)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking member changes.

  ## Examples

      iex> change_member(member)
      %Ecto.Changeset{data: %Member{}}

  """
  def change_member(%Member{} = member, attrs \\ %{}) do
    Member.changeset(member, attrs)
  end

  alias Sportyweb.Membership.MemberGroup

  @doc """
  Returns the list of member_groups.

  ## Examples

      iex> list_member_groups()
      [%MemberGroup{}, ...]

  """
  def list_member_groups do
    Repo.all(MemberGroup)
  end

  @doc """
  Gets a single member_group.

  Raises `Ecto.NoResultsError` if the Member group does not exist.

  ## Examples

      iex> get_member_group!(123)
      %MemberGroup{}

      iex> get_member_group!(456)
      ** (Ecto.NoResultsError)

  """
  def get_member_group!(id), do: Repo.get!(MemberGroup, id)

  @doc """
  Creates a member_group.

  ## Examples

      iex> create_member_group(%{field: value})
      {:ok, %MemberGroup{}}

      iex> create_member_group(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_member_group(attrs \\ %{}) do
    %MemberGroup{}
    |> MemberGroup.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a member_group.

  ## Examples

      iex> update_member_group(member_group, %{field: new_value})
      {:ok, %MemberGroup{}}

      iex> update_member_group(member_group, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_member_group(%MemberGroup{} = member_group, attrs) do
    member_group
    |> MemberGroup.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a member_group.

  ## Examples

      iex> delete_member_group(member_group)
      {:ok, %MemberGroup{}}

      iex> delete_member_group(member_group)
      {:error, %Ecto.Changeset{}}

  """
  def delete_member_group(%MemberGroup{} = member_group) do
    Repo.delete(member_group)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking member_group changes.

  ## Examples

      iex> change_member_group(member_group)
      %Ecto.Changeset{data: %MemberGroup{}}

  """
  def change_member_group(%MemberGroup{} = member_group, attrs \\ %{}) do
    MemberGroup.changeset(member_group, attrs)
  end
end
