defmodule WebtritAdapter.SessionTest do
  use WebtritAdapter.DataCase

  alias WebtritAdapter.Session

  describe "otps" do
    alias WebtritAdapter.Session.Otp

    import WebtritAdapter.SessionFixtures

    @invalid_attrs %{user_id: nil, attempt_count: nil, verified: nil, demo: nil, ignore: nil}

    test "list_otps/0 returns all otps" do
      otp = otp_fixture()
      assert Session.list_otps() == [otp]
    end

    test "get_otp!/1 returns the otp with given id" do
      otp = otp_fixture()
      assert Session.get_otp!(otp.id) == otp
    end

    test "create_otp/1 with valid data creates a otp" do
      valid_attrs = %{user_id: "some user_id", attempt_count: 42, verified: true, demo: true, ignore: true}

      assert {:ok, %Otp{} = otp} = Session.create_otp(valid_attrs)
      assert otp.user_id == "some user_id"
      assert otp.attempt_count == 42
      assert otp.verified == true
      assert otp.demo == true
      assert otp.ignore == true
    end

    test "create_otp/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Session.create_otp(@invalid_attrs)
    end

    test "update_otp/2 with valid data updates the otp" do
      otp = otp_fixture()
      update_attrs = %{user_id: "some updated user_id", attempt_count: 43, verified: false, demo: false, ignore: false}

      assert {:ok, %Otp{} = otp} = Session.update_otp(otp, update_attrs)
      assert otp.user_id == "some updated user_id"
      assert otp.attempt_count == 43
      assert otp.verified == false
      assert otp.demo == false
      assert otp.ignore == false
    end

    test "update_otp/2 with invalid data returns error changeset" do
      otp = otp_fixture()
      assert {:error, %Ecto.Changeset{}} = Session.update_otp(otp, @invalid_attrs)
      assert otp == Session.get_otp!(otp.id)
    end

    test "delete_otp/1 deletes the otp" do
      otp = otp_fixture()
      assert {:ok, %Otp{}} = Session.delete_otp(otp)
      assert_raise Ecto.NoResultsError, fn -> Session.get_otp!(otp.id) end
    end

    test "change_otp/1 returns a otp changeset" do
      otp = otp_fixture()
      assert %Ecto.Changeset{} = Session.change_otp(otp)
    end
  end
end
