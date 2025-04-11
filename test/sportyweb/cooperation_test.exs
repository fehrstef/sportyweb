defmodule Sportyweb.CooperationTest do
  use Sportyweb.DataCase

  alias Sportyweb.Cooperation

  describe "requests" do
    alias Sportyweb.Cooperation.Request

    import Sportyweb.CooperationFixtures

    @invalid_attrs %{
      author_first_name: nil,
      author_last_name: nil,
      confirmation_required: nil,
      confirmation_mail: nil
    }

    test "list_requests/0 returns all requests" do
      request = request_fixture()
      assert Cooperation.list_requests() == [request]
    end

    test "get_request!/1 returns the request with given id" do
      request = request_fixture()
      assert Cooperation.get_request!(request.id) == request
    end

    test "create_request/1 with valid data creates a request" do
      valid_attrs = %{
        author_first_name: "some author_first_name",
        author_last_name: "some author_last_name",
        confirmation_required: true,
        confirmation_mail: "some confirmation_mail"
      }

      assert {:ok, %Request{} = request} = Cooperation.create_request(valid_attrs)
      assert request.author_first_name == "some author_first_name"
      assert request.author_last_name == "some author_last_name"
      assert request.confirmation_required == true
      assert request.confirmation_mail == "some confirmation_mail"
    end

    test "create_request/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Cooperation.create_request(@invalid_attrs)
    end

    test "update_request/2 with valid data updates the request" do
      request = request_fixture()

      update_attrs = %{
        author_first_name: "some updated author_first_name",
        author_last_name: "some updated author_last_name",
        confirmation_required: false,
        confirmation_mail: "some updated confirmation_mail"
      }

      assert {:ok, %Request{} = request} = Cooperation.update_request(request, update_attrs)
      assert request.author_first_name == "some updated author_first_name"
      assert request.author_last_name == "some updated author_last_name"
      assert request.confirmation_required == false
      assert request.confirmation_mail == "some updated confirmation_mail"
    end

    test "update_request/2 with invalid data returns error changeset" do
      request = request_fixture()
      assert {:error, %Ecto.Changeset{}} = Cooperation.update_request(request, @invalid_attrs)
      assert request == Cooperation.get_request!(request.id)
    end

    test "delete_request/1 deletes the request" do
      request = request_fixture()
      assert {:ok, %Request{}} = Cooperation.delete_request(request)
      assert_raise Ecto.NoResultsError, fn -> Cooperation.get_request!(request.id) end
    end

    test "change_request/1 returns a request changeset" do
      request = request_fixture()
      assert %Ecto.Changeset{} = Cooperation.change_request(request)
    end
  end
end
