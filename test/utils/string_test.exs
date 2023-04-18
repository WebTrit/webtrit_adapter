defmodule Utils.StringTest do
  use ExUnit.Case
  alias Utils.String

  describe "camelize/1" do
    test "camelize with default option" do
      assert String.camelize("hello_world") == "HelloWorld"
      assert String.camelize("hello-world") == "HelloWorld"
      assert String.camelize("HelloWorld") == "HelloWorld"
      assert String.camelize("helloWorld") == "HelloWorld"
      assert String.camelize(:hello_world) == "HelloWorld"
    end

    test "camelize with :upper option" do
      assert String.camelize("hello_world", :upper) == "HelloWorld"
      assert String.camelize("hello-world", :upper) == "HelloWorld"
      assert String.camelize("HelloWorld", :upper) == "HelloWorld"
      assert String.camelize("helloWorld", :upper) == "HelloWorld"
      assert String.camelize(:hello_world, :upper) == "HelloWorld"
    end

    test "camelize with :lower option" do
      assert String.camelize("hello_world", :lower) == "helloWorld"
      assert String.camelize("hello-world", :lower) == "helloWorld"
      assert String.camelize("HelloWorld", :lower) == "helloWorld"
      assert String.camelize("helloWorld", :lower) == "helloWorld"
      assert String.camelize(:hello_world, :lower) == "helloWorld"
    end
  end

  describe "underscore/1" do
    test "underscore words" do
      assert String.underscore("HelloWorld") == "hello_world"
      assert String.underscore("helloWorld") == "hello_world"
      assert String.underscore("Hello-World") == "hello_world"
      assert String.underscore("hello_world") == "hello_world"
    end
  end
end
