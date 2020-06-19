defmodule HamlTest do
  use ExUnit.Case

  json = File.read!(Path.dirname(__ENV__.file) <> "/tests.json")
  contexts = Jason.decode!(json)
  for {ctx, tests} <- contexts do
    for {name, tst} <- tests do
       test "test_spec: #{ctx} (#{name})" do
         tst = unquote(Macro.escape(tst))
         html = tst["html"]
         haml = tst["haml"]
         locals = for {k, v} <- tst["locals"] || %{}, into: %{}, do: {String.to_atom(k), v}
         options = for {k, v} <- tst["config"] || %{}, into: %{}, do: {String.to_atom(k), v}
         options = if options[:format] do
           Map.put(options, :format, String.to_atom(options[:format]))
         else
           options
         end
         engine = Hamlex.engine(haml, options)
         result = Hamlex.render(engine, locals)

         assert (result |> String.trim) == html
       end
    end
  end
end
