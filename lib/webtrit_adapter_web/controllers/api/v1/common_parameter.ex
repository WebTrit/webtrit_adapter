defmodule WebtritAdapterWeb.Api.V1.CommonParameter do
  require OpenApiSpex

  alias OpenApiSpex.Schema

  def page() do
    {
      :page,
      [
        in: :query,
        schema: %Schema{type: :integer, minimum: 1, default: 1}
      ]
    }
  end

  def items_per_page() do
    {
      :items_per_page,
      [
        in: :query,
        schema: %Schema{type: :integer, minimum: 1, default: 100}
      ]
    }
  end
end
