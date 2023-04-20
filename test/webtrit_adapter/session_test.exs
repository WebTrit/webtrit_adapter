defmodule WebtritAdapter.SessionTest do
  use WebtritAdapter.DataCase

  alias WebtritAdapter.Session

  describe "otps" do
    alias WebtritAdapter.Session.Otp

    import WebtritAdapter.SessionFixtures

    test "list_otps/0 returns all otps" do
      otp = otp_fixture()
      assert Session.list_otps() == [otp]
    end

    test "get_otp!/1 returns the otp with given id" do
      otp = otp_fixture()
      assert Session.get_otp!(otp.id) == otp
    end

    test "inc_attempt_count_and_get_otp/1 increment attempt_count by 1" do
      otp = otp_fixture()
      assert otp.attempt_count == 0
      otp = Session.inc_attempt_count_and_get_otp!(otp.id)
      assert otp.attempt_count == 1
      otp = Session.inc_attempt_count_and_get_otp!(otp.id)
      assert otp.attempt_count == 2
    end

    test "create_otp/1 with valid data creates a otp" do
      valid_attrs = %{i_account: 123, demo: true, ignore: true}

      assert {:ok, %Otp{} = otp} = Session.create_otp(valid_attrs)
      assert otp.i_account == 123
      assert otp.attempt_count == 0
      assert otp.verified == false
      assert otp.demo == true
      assert otp.ignore == true
    end

    test "create_otp/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Session.create_otp(%{i_account: nil})
      assert {:error, %Ecto.Changeset{}} = Session.create_otp(%{i_account: "some string"})
    end

    test "update_otp/2 with valid data updates the otp" do
      otp = otp_fixture()

      assert {:ok, %Otp{} = otp} = Session.update_otp(otp, %{attempt_count: 100})
      assert otp.i_account == 1
      assert otp.attempt_count == 100
      assert otp.verified == false
      assert otp.demo == true
      assert otp.ignore == true

      assert {:ok, %Otp{} = otp} = Session.update_otp(otp, %{verified: true})
      assert otp.i_account == 1
      assert otp.attempt_count == 100
      assert otp.verified == true
      assert otp.demo == true
      assert otp.ignore == true
    end

    test "update_otp/2 with invalid data returns error changeset" do
      otp = otp_fixture()
      assert {:error, %Ecto.Changeset{}} = Session.update_otp(otp, %{attempt_count: -1})
      assert otp == Session.get_otp!(otp.id)
    end

    test "delete_otp/1 deletes the otp" do
      otp = otp_fixture()
      assert {:ok, %Otp{}} = Session.delete_otp(otp)
      assert_raise Ecto.NoResultsError, fn -> Session.get_otp!(otp.id) end
    end
  end
end
