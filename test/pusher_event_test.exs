Code.require_file "test_helper.exs", __DIR__

defmodule Poxa.PusherEventTest do
  use ExUnit.Case
  import Poxa.PusherEvent

  setup do
    :meck.new :gproc
  end

  teardown do
    :meck.unload :gproc
  end

  doctest Poxa.PusherEvent

  test "valid? for valid event" do
    assert valid?([{"name", "publish"}, {"data", "{ \"key\" : \"value\" }"}])
  end

  test "valid? for event without \"name\"" do
    refute valid?([{"names", "publish"}, {"data", "{ \"key\" : \"value\" }"}])
  end

  test "valid? for event without \"data\"" do
    refute valid?([{"name", "publish"}, {"dat", "{ \"key\" : \"value\" }"}])
  end

  test "connection established output" do
    json = "{\"event\":\"pusher:connection_established\",\"data\":{\"socket_id\":\"SocketId\"}}"
    assert connection_established("SocketId") == json
  end

  test "subscription established output" do
    json = "{\"event\":\"pusher_internal:subscription_succeeded\",\"data\":[]}"
    assert subscription_succeeded == json
  end

  test "subscription error output" do
    json = "{\"event\":\"pusher:subscription_error\",\"data\":[]}"
    assert subscription_error == json
  end

  test "pong output" do
    json = "{\"event\":\"pusher:pong\",\"data\":[]}"
    assert pong == json
  end

  test "presence member added output" do
    json = "{\"event\":\"pusher_internal:member_added\",\"channel\":\"channel\",\"data\":{\"user_id\":\"userid\",\"user_info\":\"userinfo\"}}"
    assert presence_member_added("channel", "userid", "userinfo") == json
  end

  test "presence member removed output" do
    json = "{\"event\":\"pusher_internal:member_removed\",\"channel\":\"channel\",\"data\":{\"user_id\":\"userid\"}}"
    assert presence_member_removed("channel", "userid") == json
  end

  test "presence subscription succeeded" do
    json = "{\"event\":\"pusher_internal:subscription_succeeded\",\"channel\":\"presence-channel\",\"data\":{\"presence\":{\"ids\":[\"userid\"],\"hash\":{\"userid\":\"userinfo\"},\"count\":1}}}"
    assert presence_subscription_succeeded("presence-channel", [{:pid, {"userid", "userinfo"}}]) == json
  end

  test "parse channels having a single channel" do
    data = [ {"channel", "channel_name"},
             {"name", "event_etc"} ]
    expected_data = [{"name", "event_etc"}]
    assert parse_channels(data) == {expected_data, ["channel_name"], nil}
  end

  test "parse channels having multiple channels" do
    data = [ {"channels", ["channel_name1", "channel_name2"]},
             {"name", "event_etc"} ]
    expected_data = [{"name", "event_etc"}]
    assert parse_channels(data) == {expected_data, ["channel_name1", "channel_name2"], nil}
  end

  test "parse channels having no channels" do
    data = [{"name", "event_etc"}]
    assert parse_channels(data) == {data, nil, nil}
  end

  test "parse channels excluding socket id" do
    data = [ {"channel", "channel_name"},
             {"name", "event_etc"},
             {"socket_id", "SocketId"}]
    expected_data = [{"name", "event_etc"}, {"socket_id", "SocketId"}]
    assert parse_channels(data) == {expected_data, ["channel_name"], "SocketId"}
  end

  test "sending message to a channel" do
    pid = self
    :meck.new JSEX
    :meck.expect(:gproc, :lookup_pids, 1, [pid])
    :meck.expect(JSEX, :encode!, 1, :msg)
    assert send_message_to_channel(:channel, [], []) == :ok
    assert_receive { ^pid, :msg }
    assert :meck.validate :gproc
    assert :meck.validate JSEX
    :meck.unload JSEX
  end

  test "sending message to a channel excluding a pid" do
    :meck.new JSEX
    :meck.expect(:gproc, :lookup_pids, 1, [self])
    :meck.expect(JSEX, :encode!, 1, :ok)
    assert send_message_to_channel(:channel, [], [self]) == :ok
    assert :meck.validate :gproc
    assert :meck.validate JSEX
    :meck.unload JSEX
  end

  test "sending message to channels" do
    pid = self
    :meck.new JSEX
    :meck.expect(:gproc, :lookup_pids, 1, [pid])
    :meck.expect(JSEX, :encode!, 1, :msg)
    assert send_message_to_channels([:channel], [], nil) == :ok
    assert_receive { ^pid, :msg }
    assert :meck.validate :gproc
    assert :meck.validate JSEX
    :meck.unload JSEX
  end

  test "sending message to channels excluding a socket id" do
    :meck.new JSEX
    :meck.expect(:gproc, :lookup_pids, 1, [self])
    :meck.expect(JSEX, :encode!, 1, :ok)
    assert send_message_to_channels([:channel], [], "SocketId") == :ok
    assert :meck.validate :gproc
    assert :meck.validate JSEX
    :meck.unload JSEX
  end
end
