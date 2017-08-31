defmodule App.Commands do
  @coinmarketcap_endpoint "https://api.coinmarketcap.com/v1/"
  @bittrex_endpoint "https://bittrex.com/api/v1.1/public/"
  @binance_endpoint "https://www.binance.com/api/v1/"

  use App.Router
  use App.Commander

  alias App.Commands.Outside
  alias App.Satoshi

  # You can create commands in the format `/command` by
  # using the macro `command "command"`.
  command ["hello", "hi"] do
    # Logger module injected from App.Commander
    Logger.info "Command /hello or /hi", commands: 1

    # You can use almost any function from the Nadia core without
    # having to specify the current chat ID as you can see below.
    # For example, `Nadia.send_message/3` takes as first argument
    # the ID of the chat you want to send this message. Using the
    # macro `send_message/2` defined at App.Commander, it is
    # injected the proper ID at the function. Go take a look.
    #
    # See also: https://hexdocs.pm/nadia/Nadia.html
    send_message "Hello World!"
  end

  # You may split code to other modules using the syntax
  # "Module, :function" instead od "do..end"
  command "outside", Outside, :outside
  # For the sake of this tutorial, I'll define everything here

  command "lsb" do
    Logger.info "Command /lsb", commands: 1
    # https://bittrex.com/api/v1.1/public/getticker?market=BTC-ETH
    # {
    #   success: true,
    #   message: "",
    #   result: {
    #     Bid: 0.11000005,
    #     Ask: 0.11000025,
    #     Last: 0.11000005
    #   }
    # }

    tickers = [
      {"Ethereum", "BTC-ETH"},
      {"Litecoin", "BTC-LTC"},
      {"Ethereum Classic", "BTC-ETC"},
      {"NEO", "BTC-NEO"},
      {"Quantum Resistant Ledger", "BTC-QRL"},
      {"Ten X", "BTC-PAY"},
    ]

    result = tickers |> Enum.map(fn({name, market}) ->
                        Task.async(fn -> {name, market, HTTPoison.get!(bittrex_ticker_endpoint(market))} end)
                     end)
                     |> Enum.map(&Task.await(&1, 30000))
                     |> Enum.reduce("", fn({name, market, resp}, acc) ->
                        %HTTPoison.Response{body: body} = resp
                        %{"success" => success, "result" => result} = Poison.decode!(body)
                        case success do
                          true ->
                            %{"Last" => last, "High" => high, "Low" => low }  = List.first(result)
                            last = Satoshi.to_i(last) |> Satoshi.humanize(round: 2)
                            # acc <> "#{name}: [#{bit_sat} bid] [#{ask_sat} ask] [#{last_sat} last] \n"
                            acc <> "#{name}: [last: #{last} sat] [high: #{high} sat] [low: #{low} sat] \n"
                          _ -> acc <> "error for GET #{bittrex_ticker_endpoint(market)} \n"
                        end
                     end)

    {:ok, _} = send_message result
  end

  command "lsbi" do
    Logger.info "Command /lsbi", commands: 1
    # https://www.binance.com/api/v1/ticker/24hr?symbol=ETHBTC
    # {
    #   priceChange: "-0.00264200",
    #   priceChangePercent: "-3.085",
    #   weightedAvgPrice: "0.08515381",
    #   prevClosePrice: "0.08564300",
    #   lastPrice: "0.08300100",
    #   bidPrice: "0.08277200",
    #   askPrice: "0.08310100",
    #   openPrice: "0.08564300",
    #   highPrice: "0.08760100",
    #   lowPrice: "0.08279400",
    #   volume: "15608.52700000",
    #   openTime: 1502446636253,
    #   closeTime: 1502533036253,
    #   fristId: 292345,
    #   lastId: 309367,
    #   count: 17023
    # }

    tickers = [
      {"Ethereum", "ETHBTC"},
      {"NEO", "NEOBTC"},
      {"GAS", "GASBTC"},
      {"BitConnect", "BCCBTC"},
      {"Binance Coin", "BNBBTC"},
      {"district0x", "DNTETH"},
    ]

    result = tickers |> Enum.map(fn({name, symbol}) ->
                        Task.async(fn -> {name, symbol, HTTPoison.get!(binance_ticker_endpoint(symbol))} end)
                     end)
                     |> Enum.map(&Task.await(&1, 30000))
                     |> Enum.reduce("", fn({name, symbol, resp}, acc) ->
                        %HTTPoison.Response{body: body, status_code: status_code} = resp
                        case status_code do
                          200 ->
                            %{"lastPrice" => last_price, "highPrice" => high_price, "lowPrice" => low_price}  = Poison.decode!(body)
                            last_price = Satoshi.to_i(String.to_float(last_price)) |> Satoshi.humanize(round: 2)
                            high_price = Satoshi.to_i(String.to_float(high_price)) |> Satoshi.humanize(round: 2)
                            low_price = Satoshi.to_i(String.to_float(low_price)) |> Satoshi.humanize(round: 2)
                            acc <> "#{name}: [last: #{last_price} sat] [high: #{high_price} sat] [low: #{low_price} sat] \n"
                          _ -> acc <> "error for GET #{binance_ticker_endpoint(symbol)} \n"
                        end
                     end)

    {:ok, _} = send_message result
  end

  command ["ls", "moon", "lambo"] do
    Logger.info "Command /ls, /moon or /lambo", commands: 1
    # https://api.coinmarketcap.com/v1/ticker/ethereum
    # {
    #     "id": "ethereum",
    #     "name": "Ethereum",
    #     "symbol": "ETH",
    #     "rank": "2",
    #     "price_usd": "376.111",
    #     "price_btc": "0.150565",
    #     "24h_volume_usd": "709202000.0",
    #     "market_cap_usd": "34845579159.0",
    #     "available_supply": "92647062.0",
    #     "total_supply": "92647062.0",
    #     "percent_change_1h": "0.32",
    #     "percent_change_24h": "1.18",
    #     "percent_change_7d": "-2.41",
    #     "last_updated": "1497966276"
    # }

    tickers = [
      "bitcoin",
      "ethereum",
      "ethereum-classic",
      "neo",
      "gas",
      "quantum-resistant-ledger",
      "tenx",
      "nimiq",
      "binance-coin",
      "district0x",
    ]

    result = tickers |> Enum.map(&Task.async(fn -> {&1, HTTPoison.get!(coinmarketcap_ticker_endpoint(&1))} end))
                     |> Enum.map(&Task.await(&1, 30000))
                     |> Enum.reduce("", fn({ticker_name, resp}, acc) ->
                        %HTTPoison.Response{body: body, status_code: status_code} = resp
                        case status_code do
                          200 ->
                            %{"name" => name, "price_usd" => price_usd, "price_btc" => price_btc} = List.first(Poison.decode!(body))
                            price_usd = Satoshi.to_sf(String.to_float(price_usd), 3)
                            price_sat = Satoshi.to_i(String.to_float(price_btc)) |> Satoshi.humanize(round: 2)
                            acc <> "#{name}: [#{price_usd} usd], [#{price_sat} sat] \n"
                          _ -> acc <> "error for GET #{coinmarketcap_ticker_endpoint(ticker_name)} \n"
                        end
                      end)

    Logger.info result

    {:ok, _} = send_message result
  end

  command "lm" do
    Logger.info "Command /lm", commands: 1
    # https://api.coinmarketcap.com/v1/ticker/
    # [
    # {
    # id: "bitcoin",
    # name: "Bitcoin",
    # symbol: "BTC",
    # rank: "1",
    # price_usd: "4590.37",
    # price_btc: "1.0",
    # 24h_volume_usd: "1802990000.0",
    # market_cap_usd: "75899986886.0",
    # available_supply: "16534612.0",
    # total_supply: "16534612.0",
    # percent_change_1h: "-0.35",
    # percent_change_24h: "0.71",
    # percent_change_7d: "9.87",
    # last_updated: "1504169964"
    # },

    trail = command_trail(update, "lm")

    resp = HTTPoison.get!(coinmarketcap_ticker_endpoint)
    %HTTPoison.Response{body: body, status_code: status_code} = resp
    result =
      case status_code do
        200 ->
          Poison.decode!(body)
          |> Enum.reduce("", fn(%{
            "name" => name,
            "price_usd" => price_usd,
            "price_btc" => price_btc,
            "percent_change_1h" => percent_change_1h,
            "percent_change_24h" => percent_change_24h,
            "percent_change_7d" => percent_change_7d,
            }, acc) ->
              price_usd = Satoshi.to_sf(String.to_float(price_usd), 3)
              price_sat = Satoshi.to_i(String.to_float(price_btc)) |> Satoshi.humanize(round: 2)
              if (String.downcase(name) =~ String.downcase(trail)) do
                acc <> "#{name}: [#{price_usd} usd], [#{price_sat} sat], [#{percent_change_1h}% 1h], [#{percent_change_24h}% 24h], [#{percent_change_7d}% 7d] \n"
              else
                acc
              end
          end)
        _ -> "error for GET #{coinmarketcap_ticker_endpoint} \n"
      end

    Logger.info result

    result = if (result == ""), do: "No match", else: result

    results = Enum.chunk_every(String.graphemes(result), 4096)
    |> Enum.map(fn(x) -> Enum.join(x, "") end)

    for result <- results do
      {:ok, _} = send_message result
    end
  end

  command "redis" do
    # Logger module injected from App.Commander
    Logger.info "Command /redis", commands: 1

    IO.inspect get_btc_from_redis_or_api

    send_message "Hello World!"
  end


  command "question" do
    Logger.info "Command /question", commands: 1

    {:ok, _} = send_message "What's the best JoJo?",
      # Nadia.Model is aliased from App.Commander
      #
      # See also: https://hexdocs.pm/nadia/Nadia.Model.InlineKeyboardMarkup.html
      reply_markup: %Model.InlineKeyboardMarkup{
        inline_keyboard: [
          [
            %{
              callback_data: "/choose joseph",
              text: "Joseph Joestar",
            },
            %{
              callback_data: "/choose joseph-of-course",
              text: "Joseph Joestar of course",
            },
          ],
          [
            # Read about fallbacks in the end of the file
            %{
              callback_data: "/typo-:p",
              text: "Other",
            },
          ]
        ]
      }
  end

  # You can create command interfaces for callback querys using this macro.
  callback_query_command "choose" do
    Logger.info "Callback Query Command /choose", commands: 1

    case update.callback_query.data do
      "/choose joseph" ->
        answer_callback_query text: "Indeed you have good taste."
      "/choose joseph-of-course" ->
        answer_callback_query text: "I can't agree more."
    end
  end

  # You may also want make commands when in inline mode.
  # Be sure to enable inline mode first: https://core.telegram.org/bots/inline
  # Try by typping "@your_bot_name /what-is something"
  inline_query_command "what-is" do
    Logger.info "Inline Query Command /what-is", commands: 1

    :ok = answer_inline_query [
      %InlineQueryResult.Article{
        id: "1",
        title: "10 Hours What is Love Jim Carrey HD",
        thumb_url: "https://img.youtube.com/vi/ER97mPHhgtM/3.jpg",
        description: "Have a great time",
        input_message_content: %{
          message_text: "https://www.youtube.com/watch?v=ER97mPHhgtM",
        }
      }
    ]
  end

  # Advanced Stuff
  #
  # Now that you already know basically how this boilerplate works let me
  # introduce you to a cool feature that happens under the hood.
  #
  # If you are used to telegram bot API, you should know that there's more
  # than one path to fetch the current message chat ID so you could answer it.
  # With that in mind and backed upon the neat macro system and the cool
  # pattern matching of Elixir, this boilerplate automatically detectes whether
  # the current message is a `inline_query`, `callback_query` or a plain chat
  # `message` and handles the current case of the Nadia method you're trying to
  # use.
  #
  # If you search for `defmacro send_message` at App.Commander, you'll see an
  # example of what I'm talking about. It just works! It basically means:
  # When you are with a callback query message, when you use `send_message` it
  # will know exatcly where to find it's chat ID. Same goes for the other kinds.

  inline_query_command "foo" do
    Logger.info "Inline Query Command /foo", commands: 1
    # Where do you think the message will go for?
    # If you answered that it goes to the user private chat with this bot,
    # you're right. Since inline querys can't receive nothing other than
    # Nadia.InlineQueryResult models. Telegram bot API could be tricky.
    send_message "This came from an inline query"
  end

  # Fallbacks

  # Rescues any unmatched callback query.
  callback_query do
    Logger.log :warn, "Did not match any callback query"

    answer_callback_query text: "Sorry, but there is no JoJo better than Joseph."
  end

  # Rescues any unmatched inline query.
  inline_query do
    Logger.log :warn, "Did not match any inline query"

    :ok = answer_inline_query [
      %InlineQueryResult.Article{
        id: "1",
        title: "Darude-Sandstorm Non non Biyori Renge Miyauchi Cover 1 Hour",
        thumb_url: "https://img.youtube.com/vi/yZi89iQ11eM/3.jpg",
        description: "Did you mean Darude Sandstorm?",
        input_message_content: %{
          message_text: "https://www.youtube.com/watch?v=yZi89iQ11eM",
        }
      }
    ]
  end

  # The `message` macro must come at the end since it matches anything.
  # You may use it as a fallback.
  message do
    Logger.log :warn, "Did not match the message"

    send_message "Try going to the /moon"
  end

  defp command_trail(update, head) do
    %Nadia.Model.Update{message: %Nadia.Model.Message{text: text}} = update
    if ("/#{head} " == String.slice(text, 0..String.length(head) + 1)) do
      String.slice(text, String.length(head) + 2..String.length(text) - 1)
    else
      ""
    end
  end

  defp btc_in_usd do
    api = "#{@coinmarketcap_endpoint}ticker/bitcoin/"
    resp = HTTPoison.get!(api)
    %HTTPoison.Response{body: body, status_code: status_code} = resp

    case status_code do
      200 ->
        %{"price_usd" => price_usd} = List.first(Poison.decode!(body))
        String.to_float(price_usd)
      _ -> 0
    end
  end

  # @res Float 3836.74
  defp get_btc_from_redis_or_api do
    {:ok, conn} = Redix.start_link()

    redis_res = Redix.command(conn, ["GET", "btc_price_usd"])
    case redis_res do
      {:ok, price} ->
        if (price != 0) && (price != nil) do
          String.to_float(price)
        else
          price = btc_in_usd
          Redix.command(conn, ["SET", "btc_price_usd", Float.to_string(price)])
          price
        end
      _ -> 0 # redis is down?
    end
  end

  defp coinmarketcap_ticker_endpoint do
    "#{@coinmarketcap_endpoint}ticker/"
  end

  defp coinmarketcap_ticker_endpoint(ticker) do
    "#{@coinmarketcap_endpoint}ticker/#{ticker}/"
  end

  defp bittrex_ticker_endpoint(market) do
    "#{@bittrex_endpoint}getmarketsummary?market=#{market}"
  end

  defp binance_ticker_endpoint(symbol) do
    "#{@binance_endpoint}ticker/24hr?symbol=#{symbol}"
  end
end
