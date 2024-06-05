defmodule WebtritAdapter.Plug.MetadataAcceptLanguageHeaderTest do
  use ExUnit.Case, async: true

  alias WebtritAdapter.Plug.MetadataAcceptLanguageHeader

  test "combine absent Accept-Language header into a nil" do
    %Plug.Conn{
      req_headers: []
    }
    |> MetadataAcceptLanguageHeader.call([])

    assert Logger.metadata()[:accept_language] == nil
  end

  test "combine empty Accept-Language header into an empty string" do
    %Plug.Conn{
      req_headers: []
    }
    |> MetadataAcceptLanguageHeader.call([])

    assert Logger.metadata()[:accept_language] == nil
  end

  test "combine one Accept-Language headers into a single string" do
    %Plug.Conn{
      req_headers: [
        {"accept-language", "uk,en-US"}
      ]
    }
    |> MetadataAcceptLanguageHeader.call([])

    assert Logger.metadata()[:accept_language] == "uk,en-US"
  end

  test "combine multiple Accept-Language headers into a single string" do
    %Plug.Conn{
      req_headers: [
        {"accept-language", "uk,en-US"},
        {"accept-language", "fr-CA;q=0.8"},
        {"accept-language", "de;q=0.6"}
      ]
    }
    |> MetadataAcceptLanguageHeader.call([])

    assert Logger.metadata()[:accept_language] == "uk,en-US, fr-CA;q=0.8, de;q=0.6"
  end
end
