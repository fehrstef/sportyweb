defmodule Sportyweb.CooperationFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Sportyweb.Cooperation` context.
  """

  @doc """
  Generate a request.
  """
  def request_fixture(attrs \\ %{}) do
    {:ok, request} =
      attrs
      |> Enum.into(%{
        author_first_name: "some author_first_name",
        author_last_name: "some author_last_name",
        confirmation_mail: "some confirmation_mail",
        confirmation_required: true
      })
      |> Sportyweb.Cooperation.create_request()

    request
  end
end
