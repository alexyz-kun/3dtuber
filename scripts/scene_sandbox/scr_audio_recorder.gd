class_name AudioRecorder
extends AudioStreamPlayer

var bus_index_record: int

# Base method

func set_up():
	bus_index_record = AudioServer.get_bus_index("Record")


# Public method

func get_audio_volume() -> float:
	return AudioServer.get_bus_peak_volume_left_db(bus_index_record, 0)
