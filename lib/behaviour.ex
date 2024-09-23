defmodule Amoxicillin.Behaviour do
  def abstract(module, with_name) do
    # module = Macro.expand(module, Macro.Env.location(__ENV__))

    func_defs =
      for {func_name, arity} <- nonprotected_functions(module) do
        args = Macro.generate_arguments(arity, module) |> Enum.map(&elem(&1, 0))

        quote do
          @callback unquote(func_name)(unquote_splicing(args)) :: any()
        end
      end

    Module.create(with_name, func_defs, Macro.Env.location(__ENV__))
  end

  defp nonprotected_functions(mod) do
    mod.module_info(:functions)
    |> Enum.reject(fn {k, _} ->
      [:__info__, :module_info] |> Enum.member?(k) ||
        String.starts_with?("#{k}", "_") ||
        String.starts_with?("#{k}", "-")
    end)
  end
end

# defmodule Amoxicillin.Behaviour do
#   def abstract(module, with_name) do
#     functions = module.__info__(:functions)

#     signatures =
#       Enum.map(functions, fn {name, arity} ->
#         args =
#           if arity == 0 do
#             []
#           else
#             Enum.map(1..arity, fn i ->
#               {String.to_atom(<<?x, ?A + i - 1>>), [], nil}
#             end)
#           end

#         {name, [], args}
#       end)

#     zipped = List.zip([signatures, functions])

#     contents =
#       for sig_func <- signatures do
#         quote do
#           @callback unquote(elem(sig_func, 0)) :: any()
#           defoverridable unquote([elem(sig_func, 1)])
#         end
#       end

#     Module.create(with_name, contents, Macro.Env.location(__ENV__))
#   end
# end
