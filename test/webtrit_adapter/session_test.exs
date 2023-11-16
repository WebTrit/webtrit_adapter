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

    test "inc_attempts_count_and_get_otp/1 increment attempts_count by 1" do
      otp = otp_fixture()
      assert otp.attempts_count == 0
      otp = Session.inc_attempts_count_and_get_otp!(otp.id)
      assert otp.attempts_count == 1
      otp = Session.inc_attempts_count_and_get_otp!(otp.id)
      assert otp.attempts_count == 2
    end

    test "create_otp/1 with valid data creates a otp" do
      valid_attrs = %{i_account: 123, demo: true, ignore: true}

      assert {:ok, %Otp{} = otp} = Session.create_otp(valid_attrs)
      assert otp.i_account == 123
      assert otp.attempts_count == 0
      assert otp.verified == false
      assert otp.demo == true
      assert otp.ignore == true
    end

    test "create_otp/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Session.create_otp()
      assert {:error, %Ecto.Changeset{}} = Session.create_otp(%{i_account: nil})
      assert {:error, %Ecto.Changeset{}} = Session.create_otp(%{i_account: "some string"})
    end

    test "update_otp/2 with valid data updates the otp" do
      otp = otp_fixture()

      assert {:ok, %Otp{} = otp} = Session.update_otp(otp, %{attempts_count: 100})
      assert otp.i_account == 1
      assert otp.attempts_count == 100
      assert otp.verified == false
      assert otp.demo == true
      assert otp.ignore == true

      assert {:ok, %Otp{} = otp} = Session.update_otp(otp, %{verified: true})
      assert otp.i_account == 1
      assert otp.attempts_count == 100
      assert otp.verified == true
      assert otp.demo == true
      assert otp.ignore == true
    end

    test "update_otp/2 with invalid data returns error changeset" do
      otp = otp_fixture()
      assert {:error, %Ecto.Changeset{}} = Session.update_otp(otp, %{attempts_count: -1})
      assert otp == Session.get_otp!(otp.id)
    end

    test "delete_otp/1 deletes the otp" do
      otp = otp_fixture()
      assert {:ok, %Otp{}} = Session.delete_otp(otp)
      assert_raise Ecto.NoResultsError, fn -> Session.get_otp!(otp.id) end
    end
  end

  describe "refresh_tokens" do
    alias WebtritAdapter.Session.RefreshToken

    import WebtritAdapter.SessionFixtures

    test "list_refresh_tokens/0 returns all refresh_tokens" do
      refresh_token = refresh_token_fixture()
      assert Session.list_refresh_tokens() == [refresh_token]
    end

    test "get_refresh_token!/1 returns the refresh_token with given id" do
      refresh_token = refresh_token_fixture()
      assert Session.get_refresh_token!(refresh_token.id) == refresh_token
    end

    test "inc_exact_usage_counter_and_get_refresh_token/1 increment usage_counter by 1" do
      refresh_token = refresh_token_fixture()
      assert refresh_token.usage_counter == 0
      refresh_token = Session.inc_exact_usage_counter_and_get_refresh_token!(refresh_token.id, 0)
      assert refresh_token.usage_counter == 1
      refresh_token = Session.inc_exact_usage_counter_and_get_refresh_token!(refresh_token.id, 1)
      assert refresh_token.usage_counter == 2
    end

    test "inc_exact_usage_counter_and_get_refresh_token/1 raise on not exact usage_counter" do
      refresh_token = refresh_token_fixture()

      assert_raise Ecto.NoResultsError, fn ->
        Session.inc_exact_usage_counter_and_get_refresh_token!(refresh_token.id, refresh_token.usage_counter + 1)
      end
    end

    test "create_refresh_token/1 with valid data creates a refresh_token" do
      valid_attrs = %{i_account: 123}

      assert {:ok, %RefreshToken{} = refresh_token} = Session.create_refresh_token(valid_attrs)
      assert refresh_token.i_account == 123
      assert refresh_token.usage_counter == 0
    end

    test "create_refresh_token/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Session.create_refresh_token()
      assert {:error, %Ecto.Changeset{}} = Session.create_refresh_token(%{i_account: nil})
      assert {:error, %Ecto.Changeset{}} = Session.create_refresh_token(%{i_account: "some string"})
    end

    test "update_refresh_token/2 with valid data updates the refresh_token" do
      refresh_token = refresh_token_fixture()
      update_attrs = %{usage_counter: 100}

      assert {:ok, %RefreshToken{} = refresh_token} = Session.update_refresh_token(refresh_token, update_attrs)
      assert refresh_token.i_account == 1
      assert refresh_token.usage_counter == 100
    end

    test "update_refresh_token/2 with invalid data returns error changeset" do
      refresh_token = refresh_token_fixture()
      assert {:error, %Ecto.Changeset{}} = Session.update_refresh_token(refresh_token, %{usage_counter: nil})
      assert refresh_token == Session.get_refresh_token!(refresh_token.id)
    end

    test "delete_refresh_token/1 deletes the refresh_token" do
      refresh_token = refresh_token_fixture()
      assert {:ok, %RefreshToken{}} = Session.delete_refresh_token(refresh_token)
      assert_raise Ecto.NoResultsError, fn -> Session.get_refresh_token!(refresh_token.id) end
    end

    test "delete_refresh_token/1 deletes the refresh_token by id" do
      refresh_token = refresh_token_fixture()
      assert {:ok, %RefreshToken{}} = Session.delete_refresh_token(refresh_token.id)
      assert_raise Ecto.NoResultsError, fn -> Session.get_refresh_token!(refresh_token.id) end
    end

    test "delete_all_refresh_token/1 deletes a refresh_tokens by i_account" do
      assert 0 == Repo.aggregate(RefreshToken, :count)
      refresh_token_fixture()
      refresh_token_fixture()
      assert 2 == Repo.aggregate(RefreshToken, :count)
      assert {2, nil} = Session.delete_all_refresh_token(1)
      assert 0 == Repo.aggregate(RefreshToken, :count)
    end
  end
end
