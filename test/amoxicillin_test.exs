defmodule AmoxicillinTest do
  use ExUnit.Case
  doctest Amoxicillin

  defmodule SomeBehaviour do
    @callback some_function() :: :ok
    @callback with_arity(param :: any()) :: :ok
  end

  setup do
    some_mock = Mox.defmock(SomeMock, for: SomeBehaviour)
    Application.ensure_all_started(:mox)

    {:ok, some_mock: some_mock}
  end

  test "should verify not called", %{
    some_mock: some_mock
  } do
    Amoxicillin.not_called_when(some_mock, :some_function, fn -> :ok end, fn ->
      Mox.UnexpectedCallError
    end)

    Amoxicillin.not_called_when(some_mock, :with_arity, fn -> :ok end, fn _ ->
      Mox.UnexpectedCallError
    end)
  end

  test "not_called_when should fail if called", %{
    some_mock: some_mock
  } do
    assert_raise(
      Mox.UnexpectedCallError,
      fn ->
        Amoxicillin.not_called_when(
          some_mock,
          :some_function,
          fn -> some_mock.some_function() end,
          fn -> raise Mox.UnexpectedCallError end
        )
      end
    )
  end

  test "should verify called", %{
    some_mock: some_mock
  } do
    Amoxicillin.called_when(
      some_mock,
      :some_function,
      fn -> :ok end,
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
      :some_function,
      fn -> :ok end,
      fn ->
        some_mock.some_function()
        some_mock.some_function()
        some_mock.some_function()
      end
    )
  end

  test "called_when should fail if not called", %{
    some_mock: some_mock
  } do
    assert_raise(
      Mox.VerificationError,
      fn ->
        Amoxicillin.called_when(
          some_mock,
          :some_function,
          fn -> :ok end,
          fn -> :ok end
        )
      end
    )
  end

  test "should verify called once", %{
    some_mock: some_mock
  } do
    Amoxicillin.called_once_when(
      some_mock,
      :some_function,
      fn -> :ok end,
      fn -> some_mock.some_function() end
    )
  end

  test "called_once_when should fail if not called", %{
    some_mock: some_mock
  } do
    assert_raise(
      Mox.VerificationError,
      fn ->
        Amoxicillin.called_once_when(
          some_mock,
          :some_function,
          fn -> :ok end,
          fn -> :ok end
        )
      end
    )
  end

  test "called_once_when should fail if called more than once", %{
    some_mock: some_mock
  } do
    assert_raise(
      Mox.UnexpectedCallError,
      fn ->
        Amoxicillin.called_once_when(
          some_mock,
          :some_function,
          fn -> :ok end,
          fn ->
            some_mock.some_function()
            some_mock.some_function()
          end
        )
      end
    )
  end

  test "should verify function exists with arity", %{
    some_mock: some_mock
  } do
    assert Amoxicillin.assert_mock(some_mock, &some_mock.with_arity/1) == :ok

    assert_raise(
      Mox.VerificationError,
      fn -> Amoxicillin.assert_mock(some_mock, &some_mock.with_arity/0) end
    )
  end

  test "should verify function arity limit", %{
    some_mock: some_mock
  } do
    assert_raise(
      Mox.VerificationError,
      fn -> Amoxicillin.assert_mock(some_mock, &some_mock.with_arity/20) end
    )
  end

  @tag skip: "Wip"
  test "should veryfy not called with function", %{
    some_mock: some_mock
  } do
    Amoxicillin.not_called_when2(some_mock, &some_mock.with_arity/1, fn -> :ok end)
  end
end
