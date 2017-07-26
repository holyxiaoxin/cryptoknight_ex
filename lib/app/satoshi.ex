defmodule App.Satoshi do
  @moduledoc """
  Provides Satoshi conversion functions.

  ## Examples

      iex> Satoshi.to_i(1)
      100000000

  """
  @satoshi_unit 100_000_000
  @one_g 1_000_000_000
  @one_m 1_000_000
  @one_k 1_000

  def to_i(amount), do: round(amount * @satoshi_unit)

  def to_sf(amount, sf) when amount == 0, do: 0

  def to_sf(amount, sf) do
    round_amount = sf - round(Float.ceil(Math.log10(amount)))
    if round_amount < 0 do
      x = String.to_integer("1" <> String.duplicate("0", -round_amount))
      round(amount/x) * x
    else
      Float.round(amount, round_amount)
    end
  end

  @doc """
  'Human-readable' output.  Use unit suffixes: Kilo, Mega, Giga, Tera and Peta.

  Returns a String.

  ## Examples

      iex> Satoshi.to_i(0.88) |> Satoshi.humanize
      "88.0M"

  """
  def humanize(sat, opts \\ [])

  def humanize(sat, opts) when sat >= @one_g do
    all_opts = [unit: @one_g, suffix: "G"] ++ opts
    do_humanize(sat, all_opts)
  end

  def humanize(sat, opts) when sat >= @one_m do
    all_opts = [unit: @one_m, suffix: "M"] ++ opts
    do_humanize(sat, all_opts)
  end

  def humanize(sat, opts) when sat >= @one_k do
    all_opts = [unit: @one_k, suffix: "K"] ++ opts
    do_humanize(sat, all_opts)
  end

  def humanize(sat, opts) do
    do_humanize(sat, [unit: 1, suffix: ""] ++ opts)
  end

  defp do_humanize(sat, unit: unit, suffix: suffix, round: round) do
    units = Float.round(sat/unit, round)
    Float.to_string(units) <> suffix
  end

  defp do_humanize(sat, unit: unit, suffix: suffix, sf: sf) do
    round_amount = Float.ceil(Math.log10(sat/unit))
    units = Float.round(sat/unit, sf - round(round_amount))
    Float.to_string(units) <> suffix
  end

  defp do_humanize(sat, unit: unit, suffix: suffix) do
    units = sat/unit
    Float.to_string(units) <> suffix
  end
end


# class Float
#   def signif(digits)
#     return 0 if self.zero?
#     self.round(-(Math.log10(self).ceil - digits))
#   end
# end
