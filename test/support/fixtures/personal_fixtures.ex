defmodule Sportyweb.PersonalFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Sportyweb.Personal` context.
  """

  import Sportyweb.OrganizationFixtures
  import Sportyweb.PolymorphicFixtures

  @doc """
  Generate a contact.
  """
  def contact_fixture(attrs \\ %{}) do
    club = club_fixture()

    {:ok, contact} =
      attrs
      |> Enum.into(%{
        club_id: club.id,
        type: "person",
        organization_name: "some organization_name",
        organization_type: "club",
        last_name: "some last_name",
        first_name_1: "some first_name_1",
        first_name_2: "some first_name_2",
        gender: "other",
        birthday: ~D[2000-02-15],
        postal_addresses: [postal_address_attrs()],
        emails: [email_attrs()],
        phones: [phone_attrs()],
        financial_data: [financial_data_attrs()],
        notes: [note_attrs()]
      })
      |> Sportyweb.Personal.create_contact()

    contact
  end

  @doc """
  Generate a contact_group.
  """
  def contact_group_fixture(attrs \\ %{}) do
    club = club_fixture()

    {:ok, contact_group} =
      attrs
      |> Enum.into(%{
        club_id: club.id
      })
      |> Sportyweb.Personal.create_contact_group()

    contact_group
  end
end
