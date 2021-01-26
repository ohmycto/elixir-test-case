defmodule GeoTasksWeb.ErrorHelpers do
  @moduledoc """
  Conveniences for translating and building error messages.
  """

  def get_result_errors(%Ecto.Changeset{} = changeset) do
    Ecto.Changeset.traverse_errors(changeset, fn {msg, _} -> msg end)
    |> Enum.flat_map(fn({key, messages}) -> Enum.map(messages, &("#{key} #{&1}")) end)
  end
  def get_result_errors(%JsonXema.ValidationError{reason: %{required: required_fields}}) do
    required_fields |> Enum.map(fn(f) -> "#{f} is missing" end)
  end
  def get_result_errors(%JsonXema.ValidationError{reason: %{properties: invalid_fields}}) do
    fields_str = invalid_fields |> Map.keys() |> Enum.join(", ")
    "The following attributes does not correspond to Task schema: #{fields_str}" |> List.wrap()
  end
  def get_result_errors(error) when is_binary(error) do
    List.wrap(error)
  end

  @doc """
  Translates an error message using gettext.
  """
  def translate_error({msg, opts}) do
    # When using gettext, we typically pass the strings we want
    # to translate as a static argument:
    #
    #     # Translate "is invalid" in the "errors" domain
    #     dgettext("errors", "is invalid")
    #
    #     # Translate the number of files with plural rules
    #     dngettext("errors", "1 file", "%{count} files", count)
    #
    # Because the error messages we show in our forms and APIs
    # are defined inside Ecto, we need to translate them dynamically.
    # This requires us to call the Gettext module passing our gettext
    # backend as first argument.
    #
    # Note we use the "errors" domain, which means translations
    # should be written to the errors.po file. The :count option is
    # set by Ecto and indicates we should also apply plural rules.
    if count = opts[:count] do
      Gettext.dngettext(GeoTasksWeb.Gettext, "errors", msg, msg, count, opts)
    else
      Gettext.dgettext(GeoTasksWeb.Gettext, "errors", msg, opts)
    end
  end
end
