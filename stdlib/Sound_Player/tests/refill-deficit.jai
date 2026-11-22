// test: only(.WINDOWS,.LINUX,.MACOS)
#import "Basic";
#import "Sound_Player";

main :: () {
    config: Sound_Player_Config;
    config.update_from_a_thread = false;
    config.audible_when_window_is_not_in_focus = true;
    config.seconds_to_fill_ahead = 0.2;
    if !sound_player_init(config) {
        sound_player_shutdown();
        print("native-device-unavailable\nok\n");
        return;
    }
    print("native-device-opened\n");
    defer sound_player_shutdown();
    properties := backend_init(config);
    #if #exists(EXPECTED_CHANNELS) assert(properties.num_channels == EXPECTED_CHANNELS);
    sleep_milliseconds(400);
    buffered, minimum := backend_count_buffered_bytes();
    assert(buffered == 0, "initial silent queue must have drained");

    pcm := s16.[0];
    data := Sound_Data.{loaded = true, type = .LINEAR_SAMPLE_ARRAY,
                       samples = pcm.data, nsamples_times_nchannels = pcm.count};
    stream := make_stream(*data);
    assert(stream != null);
    set_repeating(stream, true);
    start_playing(stream);
    update_from_async_thread(false);
    expected := minimum / (properties.num_channels * 2);
    assert(stream.samples_streamed_since_entity_update == expected, "one producer update must fill the entire measured deficit");
    print("ok\n");
}
