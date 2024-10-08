defmodule Amoxicillin do
  @moduledoc false
  alias Amoxicillin.Behaviour

  @max_arity_supported 5

  def not_called_when(fun_ptr, when_fun) do
    module = get_module(fun_ptr)
    assert_mock(module, fun_ptr)
    not_called_fun = fun_ptr |> fun_arity |> raise_function()
    mock = defmock(module)

    not_called(mock, fun_name(fun_ptr), not_called_fun)
    when_fun.()
  end

  def called_when(fun_ptr, when_function)
      when is_function(when_function) do
    dummy_function = fun_ptr |> fun_arity |> dummy_function()
    function_name = fun_name(fun_ptr)
    module = get_module(fun_ptr) |> defmock()

    Mox.expect(
      module,
      function_name,
      dummy_function
    )

    Mox.stub(
      module,
      function_name,
      dummy_function
    )

    when_function.()
    Mox.verify!()
  end

  def not_called(fun_ptr) do
    module = get_module(fun_ptr)
    raise_function = fun_ptr |> fun_arity |> raise_function()
    function_name = fun_name(fun_ptr)
    mock = defmock(module)

    Mox.expect(
      mock,
      function_name,
      raise_function
    )
  end

  def called_once_when(fun_ptr, when_function) do
    called_times_when(fun_ptr, 1, when_function)
  end

  def called_twice_when(fun_ptr, when_function) do
    called_times_when(fun_ptr, 2, when_function)
  end

  def called_times_when(fun_ptr, times, when_function) do
    dummy_function = fun_ptr |> fun_arity |> dummy_function()
    function_name = fun_name(fun_ptr)
    mock = get_module(fun_ptr) |> defmock()

    Mox.expect(
      mock,
      function_name,
      times,
      dummy_function
    )

    when_function.()
    Mox.verify!()
  end

  defp defmock(module) do
    mock_name = "#{module}_Mock_#{:rand.uniform(100_000)}" |> String.to_atom()
    location = Macro.Env.location(__ENV__)
    IO.inspect(location)

    with {:module, behaviour, _, _} <- Behaviour.abstract(module, mock_name) do
      #  false <- module_compiled?(module) do
      Mox.defmock(module, for: behaviour)
    else
      _ ->
        raise Mox.VerificationError,
              "Module #{inspect(module)} is not a mock."
    end
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

  defp not_called(mock, function_name, raise_function) do
    Mox.expect(
      mock,
      function_name,
      raise_function
    )
  end

  defp get_module(fun_ptr) do
    :erlang.fun_info(fun_ptr)[:module]
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
