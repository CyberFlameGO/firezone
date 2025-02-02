defmodule FzHttpWeb.Events do
  @moduledoc """
  Handles interfacing with other processes in the system.
  """

  alias FzHttp.{Devices, Rules}

  def create_device do
    GenServer.call(vpn_pid(), :create_device)
  end

  # set_config is used because devices need to be re-evaluated in case a
  # device is added to a User that's not active.
  def update_device(_device) do
    GenServer.call(vpn_pid(), {:set_config, Devices.to_peer_list()})
  end

  def delete_device(device_pubkey) when is_binary(device_pubkey) do
    GenServer.call(vpn_pid(), {:delete_device, device_pubkey})
  end

  def delete_device(device) when is_struct(device) do
    GenServer.call(vpn_pid(), {:delete_device, device.public_key})
  end

  def add_rule(rule) do
    GenServer.call(wall_pid(), {:add_rule, Rules.nftables_spec(rule)})
  end

  def delete_rule(rule) do
    GenServer.call(wall_pid(), {:delete_rule, Rules.nftables_spec(rule)})
  end

  def set_config do
    GenServer.call(vpn_pid(), {:set_config, Devices.to_peer_list()})
  end

  def set_rules do
    GenServer.call(wall_pid(), {:set_rules, Rules.to_nftables()})
  end

  def vpn_pid do
    :global.whereis_name(:fz_vpn_server)
  end

  def wall_pid do
    :global.whereis_name(:fz_wall_server)
  end
end
