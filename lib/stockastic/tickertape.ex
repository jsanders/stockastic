defmodule Stockastic.Tickertape do
  def connect!(account, exchange) do
    ws = Socket.Web.connect!("www.stockfighter.io", path: "/ob/api/ws/#{account}/venues/#{exchange}/tickertape", secure: true)
    [ account, exchange, ws ]
  end

  def loop!([ account, exchange, ws ], callback) do
    case Socket.Web.recv(ws) do
      {:ok, {:text, text}} ->
        callback.(text)
      {:ok, {:ping, cookie}} ->
        IO.puts "Got ping"
        Socket.Web.pong(ws, cookie || "")
      {:ok, {:close, :protocol_error, reason }} ->
        IO.puts "Received close (#{reason}), reconnecting…"
        [ _, _, ws ] = connect!(account, exchange)
      packet ->
        raise "Unknown packet: #{inspect(packet)}"
    end
    loop!([ account, exchange, ws ], callback)
  end
  
end
