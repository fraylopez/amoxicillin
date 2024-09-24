defmodule AmoxicillinTest do
  use ExUnit.Case
  doctest Amoxicillin

  defmodule SomeBehaviour do
    @callback some_function() :: :ok
    @callback with_arity(param :: any()) :: :ok
  end

  defmodule SomeModule do
    def some_function() do
      :ok
    end

    def with_arity(_param) do
      :ok
    end
  end

  defmodule SomeCallerModule do
    def some_function() do
      SomeModule.some_function()
    end
  end

  setup_all do
    some_mock = Mox.defmock(SomeModuleMock, for: SomeBehaviour)
    Application.ensure_all_started(:mox)

    {:ok, some_mock: some_mock}
  end

  describe "called_when" do
    test "should verify called" do
      Amoxicillin.called_when(
        &SomeModule.some_function/0,
        fn ->
          SomeModule.some_function()
        end
      )
    end

    test "should verify called when called more than once" do
      Amoxicillin.called_when(
        &SomeModule.some_function/0,
        fn ->
          SomeModule.some_function()
          SomeModule.some_function()
          SomeModule.some_function()
        end
      )
    end

    test "should fail if not called" do
      assert_raise(
        Mox.VerificationError,
        fn ->
          Amoxicillin.called_when(
            &SomeModule.some_function/0,
            fn -> :ok end
          )
        end
      )
    end
  end

  describe "called_once_when" do
    test "should verify called once" do
      Amoxicillin.called_once_when(
        &SomeModule.some_function/0,
        fn -> SomeCallerModule.some_function() end
      )
    end

    test "should fail if not called" do
      assert_raise(
        Mox.VerificationError,
        fn ->
          Amoxicillin.called_once_when(
            &SomeModule.some_function/0,
            fn -> :ok end
          )
        end
      )
    end

    test "should fail if called more than once" do
      assert_raise(
        Mox.UnexpectedCallError,
        fn ->
          Amoxicillin.called_once_when(
            &SomeModule.some_function/0,
            fn ->
              SomeModule.some_function()
              SomeModule.some_function()
            end
          )
        end
      )
    end
  end

  describe "called_twice_when" do
    test "should verify called twice" do
      Amoxicillin.called_twice_when(
        &SomeModule.some_function/0,
        fn ->
          SomeModule.some_function()
          SomeModule.some_function()
        end
      )
    end

    test "should fail if not called" do
      assert_raise(
        Mox.VerificationError,
        fn ->
          Amoxicillin.called_twice_when(
            &SomeModule.some_function/0,
            fn -> :ok end
          )
        end
      )
    end

    test "should fail if called once" do
      assert_raise(
        Mox.VerificationError,
        fn ->
          Amoxicillin.called_twice_when(
            &SomeModule.some_function/0,
            fn ->
              SomeModule.some_function()
            end
          )
        end
      )
    end
  end

  describe "called_times_when" do
    test "should verify called n" do
      Amoxicillin.called_times_when(
        &SomeModule.some_function/0,
        3,
        fn ->
          SomeModule.some_function()
          SomeModule.some_function()
          SomeModule.some_function()
        end
      )
    end

    test "should fail if not called" do
      assert_raise(
        Mox.VerificationError,
        fn ->
          Amoxicillin.called_times_when(
            &SomeModule.some_function/0,
            3,
            fn -> :ok end
          )
        end
      )
    end

    test "should fail if called n-1" do
      assert_raise(
        Mox.VerificationError,
        fn ->
          Amoxicillin.called_times_when(
            &SomeModule.some_function/0,
            3,
            fn ->
              SomeModule.some_function()
              SomeModule.some_function()
            end
          )
        end
      )
    end

    test "should fail if called n+1" do
      assert_raise(
        Mox.UnexpectedCallError,
        fn ->
          Amoxicillin.called_times_when(
            &SomeModule.some_function/0,
            3,
            fn ->
              SomeModule.some_function()
              SomeModule.some_function()
              SomeModule.some_function()
              SomeModule.some_function()
            end
          )
        end
      )
    end
  end

  describe "not_called_when" do
    test "should verify function arity limit" do
      assert_raise(
        Mox.VerificationError,
        fn -> Amoxicillin.not_called_when(&SomeModule.with_arity/20, fn -> :ok end) end
      )
    end

    test "should assert not called" do
      Amoxicillin.not_called_when(&SomeModule.with_arity/1, fn -> :ok end)
    end

    test "should fail when not called" do
      assert_raise(
        Mox.UnexpectedCallError,
        fn ->
          Amoxicillin.not_called_when(&SomeModule.with_arity/1, fn ->
            SomeModule.with_arity(1)
          end)
        end
      )
    end
  end
end
