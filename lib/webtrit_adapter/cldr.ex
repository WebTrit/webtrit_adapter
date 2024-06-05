defmodule WebtritAdapter.Cldr do
  use Cldr,
    otp_app: :webtrit_adapter,
    default_locale: "en",
    locales: ["en"],
    add_fallback_locales: false,
    force_locale_download: false,
    suppress_warnings: true,
    generate_docs: true
end
