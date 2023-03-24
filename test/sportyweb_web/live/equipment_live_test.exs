defmodule SportywebWeb.EquipmentLiveTest do
  use SportywebWeb.ConnCase

  import Phoenix.LiveViewTest
  import Sportyweb.AccountsFixtures
  import Sportyweb.AssetFixtures
  import Sportyweb.RBAC.RoleFixtures
  import Sportyweb.RBAC.UserRoleFixtures

  @create_attrs %{commission_at: ~D[2022-11-10], decommission_at: ~D[2022-11-15], description: "some description", name: "some name", purchased_at: ~D[2022-11-05], reference_number: "some reference_number", serial_number: "some serial_number"}
  @update_attrs %{commission_at: ~D[2022-11-11], decommission_at: ~D[2022-11-16], description: "some updated description", name: "some updated name", purchased_at: ~D[2022-11-06], reference_number: "some updated reference_number", serial_number: "some updated serial_number"}
  @invalid_attrs %{commission_at: nil, decommission_at: nil, description: nil, name: nil, purchased_at: nil, reference_number: nil, serial_number: nil}

  setup do
    user = user_fixture()
    applicationrole = application_role_fixture()
    user_application_role_fixture(%{user_id: user.id, applicationrole_id: applicationrole.id})

    %{user: user}
  end

  defp create_equipment(_) do
    equipment = equipment_fixture()
    %{equipment: equipment}
  end

  describe "Index" do
    setup [:create_equipment]

    test "lists all equipment - default redirect", %{conn: conn, user: user} do
      {:error, _} = live(conn, ~p"/equipment")

      conn = conn |> log_in_user(user)
      {:ok, conn} =
        conn
        |> live(~p"/equipment")
        |> follow_redirect(conn, ~p"/clubs")

      assert conn.resp_body =~ "Vereinsübersicht"
    end

    test "lists all equipment - redirect", %{conn: conn, user: user, equipment: equipment} do
      {:error, _} = live(conn, ~p"/venues/#{equipment.venue_id}/equipment")

      conn = conn |> log_in_user(user)
      {:ok, conn} =
        conn
        |> live(~p"/venues/#{equipment.venue_id}/equipment")
        |> follow_redirect(conn, ~p"/venues/#{equipment.venue_id}")

      assert conn.resp_body =~ "Standort:"
    end
  end

  describe "New/Edit" do
    setup [:create_equipment]

    test "saves new equipment", %{conn: conn, user: user} do
      venue = venue_fixture()

      {:error, _} = live(conn, ~p"/venues/#{venue}/equipment/new")

      conn = conn |> log_in_user(user)
      {:ok, new_live, html} = live(conn, ~p"/venues/#{venue}/equipment/new")

      assert html =~ "Equipment erstellen"

      assert new_live
              |> form("#equipment-form", equipment: @invalid_attrs)
              |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        new_live
        |> form("#equipment-form", equipment: @create_attrs)
        |> render_submit()
        |> follow_redirect(conn, ~p"/venues/#{venue}")

      assert html =~ "Equipment erfolgreich erstellt"
      assert html =~ "some name"
    end

    test "cancels save new equipment", %{conn: conn, user: user} do
      venue = venue_fixture()

      conn = conn |> log_in_user(user)
      {:ok, new_live, _html} = live(conn, ~p"/venues/#{venue}/equipment/new")

      {:ok, _, _html} =
        new_live
        |> element("#equipment-form a", "Abbrechen")
        |> render_click()
        |> follow_redirect(conn, ~p"/venues/#{venue}")
    end

    test "updates equipment", %{conn: conn, user: user, equipment: equipment} do
      {:error, _} = live(conn, ~p"/equipment/#{equipment}/edit")

      conn = conn |> log_in_user(user)
      {:ok, edit_live, html} = live(conn, ~p"/equipment/#{equipment}/edit")

      assert html =~ "Equipment bearbeiten"

      assert edit_live
             |> form("#equipment-form", equipment: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        edit_live
        |> form("#equipment-form", equipment: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, ~p"/equipment/#{equipment}")

      assert html =~ "Equipment erfolgreich aktualisiert"
      assert html =~ "some updated name"
    end

    test "cancels updates equipment", %{conn: conn, user: user, equipment: equipment} do
      conn = conn |> log_in_user(user)
      {:ok, edit_live, _html} = live(conn, ~p"/equipment/#{equipment}/edit")

      {:ok, _, _html} =
        edit_live
        |> element("#equipment-form a", "Abbrechen")
        |> render_click()
        |> follow_redirect(conn, ~p"/equipment/#{equipment}")
    end

    test "deletes equipment", %{conn: conn, user: user, equipment: equipment} do
      {:error, _} = live(conn, ~p"/equipment/#{equipment}/edit")

      conn = conn |> log_in_user(user)
      {:ok, edit_live, html} = live(conn, ~p"/equipment/#{equipment}/edit")
      assert html =~ "some serial_number"

      {:ok, _, html} =
        edit_live
        |> element("#equipment-form button", "Löschen")
        |> render_click()
        |> follow_redirect(conn, ~p"/venues/#{equipment.venue_id}")

      assert html =~ "Equipment erfolgreich gelöscht"
      assert html =~ "Equipment"
      refute html =~ "some serial_number"
    end
  end

  describe "Show" do
    setup [:create_equipment]

    test "displays equipment", %{conn: conn, user: user, equipment: equipment} do
      {:error, _} = live(conn, ~p"/equipment/#{equipment}")

      conn = conn |> log_in_user(user)
      {:ok, _show_live, html} = live(conn, ~p"/equipment/#{equipment}")

      assert html =~ "Equipment:"
      assert html =~ equipment.name
    end
  end
end