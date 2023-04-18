defmodule Utils.MapTest do
  use ExUnit.Case, async: true

  alias Utils.Map, as: UMap

  describe "deep_filter_blank_values/1" do
    test "filter nil values from nested maps" do
      input_map = %{
        a: 1,
        b: nil,
        c: %{
          d: 2,
          e: nil,
          f: %{
            g: 3,
            h: nil
          }
        }
      }

      expected_map = %{
        a: 1,
        c: %{
          d: 2,
          f: %{
            g: 3
          }
        }
      }

      assert UMap.deep_filter_blank_values(input_map) == expected_map
    end

    test "returns an empty map when input is an empty map" do
      assert UMap.deep_filter_blank_values(%{}) == %{}
    end

    test "does not modify the input map if it contains no nil values" do
      input_map = %{
        a: 1,
        b: 2,
        c: %{
          d: 3,
          e: %{
            f: 4
          }
        }
      }

      assert UMap.deep_filter_blank_values(input_map) == input_map
    end
  end
end
