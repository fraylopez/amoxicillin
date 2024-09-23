defmodule AmoxicillinTest do
  use ExUnit.Case
  doctest Amoxicillin

  defmodule SomeBehaviour do
    @callback some_function() :: :ok
    @callback with_arity(param :: any()) :: :ok
  end

  setup_all do
    some_mock = Mox.defmock(SomeMock, for: SomeBehaviour)
    Application.ensure_all_started(:mox)

    {:ok, some_mock: some_mock}
  end

  describe "called_when" do
    test "should verify called", %{
      some_mock: some_mock
    } do
      Amoxicillin.called_when(
        some_mock,
        &some_mock.some_function/0,
        fn ->
          some_mock.some_function()
        end
      )
    end

    test "should verify called when called more than once", %{
      some_mock: some_mock
    } do
      Amoxicillin.called_when(
        some_mock,
        &some_mock.some_function/0,
        fn ->
          some_mock.some_function()
          some_mock.some_function()
          some_mock.some_function()
        end
      )
    end

    test "should fail if not called", %{
      some_mock: some_mock
    } do
      assert_raise(
        Mox.VerificationError,
        fn ->
          Amoxicillin.called_when(
            some_mock,
            &some_mock.some_function/0,
            fn -> :ok end
          )
        end
      )
    end
  end

  describe "called_once_when" do
    test "should verify called once", %{
      some_mock: some_mock
    } do
      Amoxicillin.called_once_when(
        some_mock,
        &some_mock.some_function/0,
        fn -> some_mock.some_function() end
      )
    end

    test "should fail if not called", %{
      some_mock: some_mock
    } do
      assert_raise(
        Mox.VerificationError,
        fn ->
          Amoxicillin.called_once_when(
            some_mock,
            &some_mock.some_function/0,
            fn -> :ok end
          )
        end
      )
    end

    test "should fail if called more than once", %{
      some_mock: some_mock
    } do
      assert_raise(
        Mox.UnexpectedCallError,
        fn ->
          Amoxicillin.called_once_when(
            some_mock,
            &some_mock.some_function/0,
            fn ->
              some_mock.some_function()
              some_mock.some_function()
            end
          )
        end
      )
    end
  end

  describe "called_twice_when" do
    test "should verify called twice", %{
      some_mock: some_mock
    } do
      Amoxicillin.called_twice_when(
        some_mock,
        &some_mock.some_function/0,
        fn ->
          some_mock.some_function()
          some_mock.some_function()
        end
      )
    end

    test "should fail if not called", %{
      some_mock: some_mock
    } do
      assert_raise(
        Mox.VerificationError,
        fn ->
          Amoxicillin.called_twice_when(
            some_mock,
            &some_mock.some_function/0,
            fn -> :ok end
          )
        end
      )
    end

    test "should fail if called once", %{
      some_mock: some_mock
    } do
      assert_raise(
        Mox.VerificationError,
        fn ->
          Amoxicillin.called_twice_when(
            some_mock,
            &some_mock.some_function/0,
            fn ->
              some_mock.some_function()
            end
          )
        end
      )
    end
  end

  describe "called_times_when" do
    test "should verify called n", %{
      some_mock: some_mock
    } do
      Amoxicillin.called_times_when(
        some_mock,
        &some_mock.some_function/0,
        3,
        fn ->
          some_mock.some_function()
          some_mock.some_function()
          some_mock.some_function()
        end
      )
    end

    test "should fail if not called", %{
      some_mock: some_mock
    } do
      assert_raise(
        Mox.VerificationError,
        fn ->
          Amoxicillin.called_times_when(
            some_mock,
            &some_mock.some_function/0,
            3,
            fn -> :ok end
          )
        end
      )
    end

    test "should fail if called n-1", %{
      some_mock: some_mock
    } do
      assert_raise(
        Mox.VerificationError,
        fn ->
          Amoxicillin.called_times_when(
            some_mock,
            &some_mock.some_function/0,
            3,
            fn ->
              some_mock.some_function()
              some_mock.some_function()
            end
          )
        end
      )
    end

    test "should fail if called n+1", %{
      some_mock: some_mock
    } do
      assert_raise(
        Mox.UnexpectedCallError,
        fn ->
          Amoxicillin.called_times_when(
            some_mock,
            &some_mock.some_function/0,
            3,
            fn ->
              some_mock.some_function()
              some_mock.some_function()
              some_mock.some_function()
              some_mock.some_function()
            end
          )
        end
      )
    end
  end

  describe "not_called_when" do
    test "should verify function arity limit", %{
      some_mock: some_mock
    } do
      assert_raise(
        Mox.VerificationError,
        fn -> Amoxicillin.not_called_when(some_mock, &some_mock.with_arity/20, fn -> :ok end) end
      )
    end

    test "should assert not called", %{
      some_mock: some_mock
    } do
      Amoxicillin.not_called_when(some_mock, &some_mock.with_arity/1, fn -> :ok end)
    end

    test "should fail when not called", %{
      some_mock: some_mock
    } do
      assert_raise(
        Mox.UnexpectedCallError,
        fn ->
          Amoxicillin.not_called_when(some_mock, &some_mock.with_arity/1, fn ->
            some_mock.with_arity(1)
          end)
        end
      )
    end
  end
end
