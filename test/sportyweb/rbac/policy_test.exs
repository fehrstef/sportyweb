defmodule Sportyweb.RBAC.PolicyTest do
  use Sportyweb.DataCase

  import Sportyweb.AccountsFixtures
  import Sportyweb.OrganizationFixtures
  import Sportyweb.RBAC.RoleFixtures
  import Sportyweb.RBAC.UserRoleFixtures

  alias Sportyweb.RBAC.Role.RolePermissionMatrix, as: RPM
  setup do
    #User
    app_admin = user_fixture()
    club_user = user_fixture()
    user_not_in_club = user_fixture()

    #ApplicationRole & UserApplicationRole
    applicationrole = application_role_fixture()
    user_application_role_fixture(%{user_id: app_admin.id, applicationrole_id: applicationrole.id})

    #Club
    club = club_fixture()

    #ClubRoles
    clubroles = :club |> RPM.get_role_names() |> Enum.map(&(club_role_fixture(%{name: &1})))

    %{
      app_admin: app_admin,
      club_user: club_user,
      user_not_in_club: user_not_in_club,
      club: club,
      clubroles: clubroles
    }
  end

  describe "policy" do
    import Sportyweb.RBAC.Policy

    alias Sportyweb.RBAC.UserRole

    test "is_application_admin_or_tester/1 checks if user has application rights", %{app_admin: user, club_user: user_c} do
      assert is_application_admin_or_tester(user)   == true
      assert is_application_admin_or_tester(user_c) == false
    end

    test "permit?/4 user to do action in ClubLive", %{club_user: user, club: club, clubroles: clubroles} do
      actions = [:index, :new, :edit, :show]
      assert [true, false, false, false] == actions |> Enum.map(&(permit?(user, &1, :ClubLive, %{id: club.id})))

      for clubrole <- clubroles do
        {:ok, ucr} = UserRole.create_user_club_role(%{user_id: user.id, club_id: club.id, clubrole_id: clubrole.id})
        case RPM.to_role_atom(:club, clubrole.name) do
          :club_admin ->                  assert [true, false, true,  true] == actions |> Enum.map(&(permit?(user, &1, :ClubLive, %{"id" => club.id}))), "Rolle: #{clubrole.name}"
          :vorstand ->                    assert [true, false, true,  true] == actions |> Enum.map(&(permit?(user, &1, :ClubLive, %{"id" => club.id}))), "Rolle: #{clubrole.name}"
          :mitarbeiter_rollen ->          assert [true, false, false, true] == actions |> Enum.map(&(permit?(user, &1, :ClubLive, %{"id" => club.id}))), "Rolle: #{clubrole.name}"
          :mitglieder_verwaltung ->       assert [true, false, false, true] == actions |> Enum.map(&(permit?(user, &1, :ClubLive, %{"id" => club.id}))), "Rolle: #{clubrole.name}"
          :anlagen_geraete_verwaltung ->  assert [true, false, false, true] == actions |> Enum.map(&(permit?(user, &1, :ClubLive, %{"id" => club.id}))), "Rolle: #{clubrole.name}"
          :finanz_verwaltung ->           assert [true, false, false, true] == actions |> Enum.map(&(permit?(user, &1, :ClubLive, %{"id" => club.id}))), "Rolle: #{clubrole.name}"
          :pr ->                          assert [true, false, false, true] == actions |> Enum.map(&(permit?(user, &1, :ClubLive, %{"id" => club.id}))), "Rolle: #{clubrole.name}"
        end
        UserRole.delete_user_club_role(ucr)
      end
    end

    test "permit?/4 user to do action in DepartmentLive", %{club_user: user, club: club, clubroles: clubroles} do
      actions = [:index, :new, :edit, :show]
      assert [false, false, false, false] == actions |> Enum.map(&(permit?(user, &1, :DepartmentLive, %{"club_id" => club.id}))), "#{user.email}"

      for clubrole <- clubroles do
        {:ok, ucr} = UserRole.create_user_club_role(%{user_id: user.id, club_id: club.id, clubrole_id: clubrole.id})
        case RPM.to_role_atom(:club, clubrole.name) do
          :club_admin ->                  assert [true, true,  true,  true]  == actions |> Enum.map(&(permit?(user, &1, :DepartmentLive, %{"club_id" => club.id}))), "Rolle: #{clubrole.name}"
          :vorstand ->                    assert [true, false, false, true]  == actions |> Enum.map(&(permit?(user, &1, :DepartmentLive, %{"club_id" => club.id}))), "Rolle: #{clubrole.name}"
          :mitarbeiter_rollen ->          assert [true, false, false, false] == actions |> Enum.map(&(permit?(user, &1, :DepartmentLive, %{"club_id" => club.id}))), "Rolle: #{clubrole.name}"
          :mitglieder_verwaltung ->       assert [true, false, false, false] == actions |> Enum.map(&(permit?(user, &1, :DepartmentLive, %{"club_id" => club.id}))), "Rolle: #{clubrole.name}"
          :anlagen_geraete_verwaltung ->  assert [true, false, false, false] == actions |> Enum.map(&(permit?(user, &1, :DepartmentLive, %{"club_id" => club.id}))), "Rolle: #{clubrole.name}"
          :finanz_verwaltung ->           assert [true, false, false, false] == actions |> Enum.map(&(permit?(user, &1, :DepartmentLive, %{"club_id" => club.id}))), "Rolle: #{clubrole.name}"
          :pr ->                          assert [true, false, false, false] == actions |> Enum.map(&(permit?(user, &1, :DepartmentLive, %{"club_id" => club.id}))), "Rolle: #{clubrole.name}"
        end
        UserRole.delete_user_club_role(ucr)
      end
    end

    test "permit?/4 user to do action in UserClubRoleLive", %{club_user: user, club: club, clubroles: clubroles} do
      actions = [:index, :new, :edit, :show]
      assert [false, false, false, false] == actions |> Enum.map(&(permit?(user, &1, :UserClubRoleLive, %{id: club.id})))

      for clubrole <- clubroles do
        {:ok, ucr} = UserRole.create_user_club_role(%{user_id: user.id, club_id: club.id, clubrole_id: clubrole.id})
        case RPM.to_role_atom(:club, clubrole.name) do
          :club_admin ->                  assert [true,  true,  true,  true]  == actions |> Enum.map(&(permit?(user, &1, :UserClubRoleLive, %{"club_id" => club.id}))), "Rolle: #{clubrole.name}"
          :vorstand ->                    assert [true,  false, false, false] == actions |> Enum.map(&(permit?(user, &1, :UserClubRoleLive, %{"club_id" => club.id}))), "Rolle: #{clubrole.name}"
          :mitarbeiter_rollen ->          assert [true,  true,  true,  true]  == actions |> Enum.map(&(permit?(user, &1, :UserClubRoleLive, %{"club_id" => club.id}))), "Rolle: #{clubrole.name}"
          :mitglieder_verwaltung ->       assert [false, false, false, false] == actions |> Enum.map(&(permit?(user, &1, :UserClubRoleLive, %{"club_id" => club.id}))), "Rolle: #{clubrole.name}"
          :anlagen_geraete_verwaltung ->  assert [false, false, false, false] == actions |> Enum.map(&(permit?(user, &1, :UserClubRoleLive, %{"club_id" => club.id}))), "Rolle: #{clubrole.name}"
          :finanz_verwaltung ->           assert [false, false, false, false] == actions |> Enum.map(&(permit?(user, &1, :UserClubRoleLive, %{"club_id" => club.id}))), "Rolle: #{clubrole.name}"
          :pr ->                          assert [false, false, false, false] == actions |> Enum.map(&(permit?(user, &1, :UserClubRoleLive, %{"club_id" => club.id}))), "Rolle: #{clubrole.name}"
        end
        UserRole.delete_user_club_role(ucr)
      end
    end
  end
end