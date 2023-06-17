defmodule WebtritAdapterClientTest do
  use ExUnit.Case

  import Tesla.Mock

  describe "adapter url with empty path" do
    setup do
      mock(fn
        %{method: :get, url: "https://example.com/api/v1/system-info"} ->
          json(%{"some" => "data"})
      end)

      :ok
    end

    for url <- [
          "https://example.com",
          "https://example.com/",
          "https://example.com/will-be-dropped"
        ] do
      test "execute get_system_info/1 on correct url: #{url}" do
        client = WebtritAdapterClient.new(unquote(url))
        assert {status, body} = WebtritAdapterClient.get_system_info(client)
        assert status == 200
        assert body != nil
      end
    end

    for url <- [
          "https://example.com/some-prefix/"
        ] do
      test "execute get_system_info/1 on incorrect url: #{url}" do
        assert_raise Tesla.Mock.Error, fn ->
          client = WebtritAdapterClient.new(unquote(url))
          WebtritAdapterClient.get_system_info(client)
        end
      end
    end
  end

  describe "adapter url with not empty path" do
    setup do
      mock(fn
        %{method: :get, url: "https://example.com/some-prefix/api/v1/system-info"} ->
          json(%{"some" => "data"})
      end)

      :ok
    end

    for url <- [
          "https://example.com/some-prefix/",
          "https://example.com/some-prefix/will-be-dropped"
        ] do
      test "execute get_system_info/1 on correct url: #{url}" do
        client = WebtritAdapterClient.new(unquote(url))
        assert {status, body} = WebtritAdapterClient.get_system_info(client)
        assert status == 200
        assert body != nil
      end
    end

    for url <- [
          "https://example.com",
          "https://example.com/",
          "https://example.com/some-prefix"
        ] do
      test "execute get_system_info/1 on incorrect url: #{url}" do
        assert_raise Tesla.Mock.Error, fn ->
          client = WebtritAdapterClient.new(unquote(url))
          WebtritAdapterClient.get_system_info(client)
        end
      end
    end
  end
end
