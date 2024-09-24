defmodule Amoxicillin.BehaviourTest do
  use ExUnit.Case
  doctest Amoxicillin.Behaviour

  alias Amoxicillin.Behaviour

  defmodule SomeModule do
    def some_function() do
      :ok
    end

    def with_arity(_param) do
      :ok
    end
  end

  test "creates a behaviour with the correct callbacks from a module" do
    res = Behaviour.abstract(SomeModule, :SomeBehaviour)

    assert res != nil
  end
end
