defmodule Amoxicillin do
  @moduledoc false

  @max_arity_supported 5

  def not_called_when(module, fun_ptr, when_fun) do
    assert_mock(module, fun_ptr)
    not_called_fun = fun_ptr |> fun_arity |> raise_function()
    not_called_when(module, fun_name(fun_ptr), when_fun, not_called_fun)
  end

  def called_when(mock, fun_ptr, when_function)
      when is_function(when_function) do
    dummy_function = fun_ptr |> fun_arity |> dummy_function()
    function_name = fun_name(fun_ptr)

    Mox.expect(
      mock,
      function_name,
      dummy_function
    )

    Mox.stub(
      mock,
      function_name,
      dummy_function
    )

    when_function.()
    Mox.verify!()
  end

  def not_called(mock, fun_ptr) do
    raise_function = fun_ptr |> fun_arity |> raise_function()
    function_name = fun_name(fun_ptr)

    Mox.expect(
      mock,
      function_name,
      raise_function
    )
  end

  def called_once_when(mock, fun_ptr, when_function) do
    called_times_when(mock, fun_ptr, 1, when_function)
  end

  def called_twice_when(mock, fun_ptr, when_function) do
    called_times_when(mock, fun_ptr, 2, when_function)
  end

  def called_times_when(mock, fun_ptr, times, when_function) do
    dummy_function = fun_ptr |> fun_arity |> dummy_function()
    function_name = fun_name(fun_ptr)

    Mox.expect(
      mock,
      function_name,
      times,
      dummy_function
    )

    when_function.()
    Mox.verify!()
  end

  defp assert_mock(module, fun_ptr) do
    fun_name = fun_name(fun_ptr)
    fun_arity = fun_arity(fun_ptr)
    functions = mod_functions(module)

    with true <- Keyword.get(functions, fun_name) != nil,
         true <- Keyword.get(functions, fun_name) == fun_arity do
      :ok
    else
      _ ->
        raise Mox.VerificationError,
              "Function #{inspect(fun_name)}/#{fun_arity} not found in module #{inspect(module)} or has wrong arity."
    end

    case fun_arity < @max_arity_supported do
      true ->
        :ok

      false ->
        raise Mox.VerificationError,
              "Arities greater than #{@max_arity_supported} are not supported."
    end
  end

  defp not_called_when(mock, function_name, when_function, raise_function)
       when is_function(when_function) do
    not_called(mock, function_name, raise_function)
    when_function.()
  end

  defp not_called(mock, function_name, raise_function) do
    Mox.expect(
      mock,
      function_name,
      raise_function
    )
  end

  defp fun_name(fun_ptr) do
    Keyword.get(:erlang.fun_info(fun_ptr), :name)
  end

  defp fun_arity(fun_ptr) do
    Keyword.get(:erlang.fun_info(fun_ptr), :arity)
  end

  defp mod_functions(module) do
    Keyword.get(module.module_info(), :exports)
  end

  defp raise_function(arity) do
    # TODO:
    # dinamically create a function with the arity of the function to be checked
    # that throws an error if called
    [
      fn -> raise Mox.UnexpectedCallError end,
      fn _ -> raise Mox.UnexpectedCallError end,
      fn _, _ -> raise Mox.UnexpectedCallError end,
      fn _, _, _ -> raise Mox.UnexpectedCallError end,
      fn _, _, _, _ -> raise Mox.UnexpectedCallError end,
      fn _, _, _, _, _ -> raise Mox.UnexpectedCallError end
    ]
    |> Enum.at(arity)
  end

  defp dummy_function(arity) do
    [
      fn -> :ok end,
      fn _ -> :ok end,
      fn _, _ -> :ok end,
      fn _, _, _ -> :ok end,
      fn _, _, _, _ -> :ok end,
      fn _, _, _, _, _ -> :ok end
    ]
    |> Enum.at(arity)
  end
end
